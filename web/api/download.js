export default async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  const url = req.query.url;
  if (!url || typeof url !== "string" || !/^https?:\/\//i.test(url)) {
    return res.status(400).json({ error: "URL video không hợp lệ" });
  }

  try {
    const response = await fetch(url, {
      headers: {
        "User-Agent": "SnapTik/1.0",
        Referer: "https://www.tiktok.com/",
      },
    });

    if (!response.ok) {
      return res.status(502).json({ error: "Không tải được video" });
    }

    const contentType = response.headers.get("content-type") || "video/mp4";
    const buffer = Buffer.from(await response.arrayBuffer());

    res.setHeader("Content-Type", contentType);
    res.setHeader("Content-Disposition", 'attachment; filename="tiktok.mp4"');
    res.setHeader("Cache-Control", "no-store");
    return res.status(200).send(buffer);
  } catch {
    return res.status(500).json({ error: "Lỗi tải video" });
  }
}
