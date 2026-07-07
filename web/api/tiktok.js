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

  if (!/tiktok\.com|vm\.tiktok\.com|vt\.tiktok\.com/i.test(url)) {
    return res.status(400).json({ error: "Link TikTok không hợp lệ" });
  }

  try {
    const apiUrl = `https://www.tikwm.com/api/?url=${encodeURIComponent(url)}&hd=1`;
    const response = await fetch(apiUrl, {
      headers: { "User-Agent": "SnapTik/1.0" },
    });

    const data = await response.json();

    if (data.code !== 0 || !data.data) {
      return res.status(502).json({
        error: data.msg || "Không lấy được video. Thử lại sau.",
      });
    }

    const d = data.data;
    return res.status(200).json({
      id: d.id,
      title: d.title || "TikTok Video",
      cover: d.cover,
      author: d.author?.nickname || "Unknown",
      username: d.author?.unique_id || "",
      duration: d.duration || 0,
      play: d.play,
      hdplay: d.hdplay,
      music: d.music,
    });
  } catch {
    return res.status(500).json({ error: "Lỗi kết nối máy chủ" });
  }
}
