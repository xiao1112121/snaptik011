export const config = { maxDuration: 60 };

async function fetchFromTikwm(url) {
  const headers = {
    "User-Agent":
      "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
    Accept: "application/json",
  };

  const postRes = await fetch("https://www.tikwm.com/api/", {
    method: "POST",
    headers: {
      ...headers,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({ url, hd: "1" }),
  });

  let data = await postRes.json().catch(() => null);

  if (!data || data.code !== 0) {
    const getRes = await fetch(
      `https://www.tikwm.com/api/?url=${encodeURIComponent(url)}&hd=1`,
      { headers }
    );
    data = await getRes.json().catch(() => null);
  }

  return data;
}

export default async function handler(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    return res.status(200).end();
  }

  const url = req.query.url;
  if (!url || typeof url !== "string") {
    return res.status(400).json({ error: "Thiếu link TikTok" });
  }

  if (!/tiktok\.com|vm\.tiktok\.com|vt\.tiktok\.com|m\.tiktok\.com/i.test(url)) {
    return res.status(400).json({ error: "Link TikTok không hợp lệ" });
  }

  try {
    const data = await fetchFromTikwm(url.trim());

    if (!data || data.code !== 0 || !data.data) {
      return res.status(502).json({
        error: data?.msg || "Không lấy được video. Thử lại sau.",
      });
    }

    const d = data.data;
    const play = d.play || d.wmplay;
    const hdplay = d.hdplay || d.play;

    if (!play) {
      return res.status(502).json({ error: "Không tìm thấy link video" });
    }

    const proxy = (videoUrl) =>
      `/api/download?url=${encodeURIComponent(videoUrl)}`;

    return res.status(200).json({
      id: d.id,
      title: d.title || "TikTok Video",
      cover: d.cover,
      author: d.author?.nickname || "Unknown",
      username: d.author?.unique_id || "",
      duration: d.duration || 0,
      play,
      hdplay: hdplay || play,
      proxyPlay: proxy(play),
      proxyHdplay: proxy(hdplay || play),
      savePage: `/save.html?url=${encodeURIComponent(hdplay || play)}`,
    });
  } catch {
    return res.status(500).json({ error: "Lỗi kết nối máy chủ" });
  }
}
