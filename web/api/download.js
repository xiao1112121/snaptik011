import { Readable } from "node:stream";
import { pipeline } from "node:stream/promises";

export const config = { maxDuration: 60 };

export default async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, HEAD, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Range, Content-Type");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  const url = req.query.url;
  if (!url || typeof url !== "string" || !/^https?:\/\//i.test(url)) {
    return res.status(400).json({ error: "URL video không hợp lệ" });
  }

  const upstreamHeaders = {
    "User-Agent":
      "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
    Referer: "https://www.tiktok.com/",
    Accept: "*/*",
  };

  if (req.headers.range) {
    upstreamHeaders.Range = req.headers.range;
  }

  try {
    const upstream = await fetch(url, { headers: upstreamHeaders });

    if (!upstream.ok && upstream.status !== 206) {
      return res.status(502).json({ error: "Không tải được video từ nguồn" });
    }

    res.status(upstream.status);

    for (const key of ["content-type", "content-length", "content-range", "accept-ranges"]) {
      const val = upstream.headers.get(key);
      if (val) res.setHeader(key, val);
    }

    if (!upstream.headers.get("content-type")) {
      res.setHeader("Content-Type", "video/mp4");
    }

    res.setHeader("Accept-Ranges", "bytes");
    res.setHeader("Cache-Control", "no-store");

    if (req.query.dl === "1") {
      res.setHeader("Content-Disposition", 'attachment; filename="tiktok.mp4"');
    } else {
      res.setHeader("Content-Disposition", 'inline; filename="tiktok.mp4"');
    }

    if (req.method === "HEAD") {
      return res.end();
    }

    if (!upstream.body) {
      return res.status(502).json({ error: "Video rỗng" });
    }

    await pipeline(Readable.fromWeb(upstream.body), res);
  } catch {
    if (!res.headersSent) {
      return res.status(500).json({ error: "Lỗi proxy video" });
    }
    res.end();
  }
}
