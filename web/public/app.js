const $ = (id) => document.getElementById(id);

const urlInput = $("url");
const clearBtn = $("clearBtn");
const pasteBtn = $("pasteBtn");
const fetchBtn = $("fetchBtn");
const hdToggle = $("hdToggle");
const statusEl = $("status");
const previewEl = $("preview");
const playerEl = $("player");
const videoEl = $("video");
const iosGuideEl = $("iosGuide");

let currentVideo = null;

const isIOS = () =>
  /iPad|iPhone|iPod/.test(navigator.userAgent) ||
  (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1);

const isTikTokURL = (url) =>
  /tiktok\.com|vm\.tiktok\.com|vt\.tiktok\.com/i.test(url);

function getVideoUrl() {
  if (!currentVideo) return null;
  const useHD = hdToggle.checked && currentVideo.hdplay;
  return useHD ? currentVideo.hdplay : currentVideo.play;
}

function proxyDownloadUrl(videoUrl) {
  return `/api/download?url=${encodeURIComponent(videoUrl)}`;
}

function showStatus(msg, type = "loading") {
  statusEl.hidden = false;
  statusEl.className = `status ${type}`;
  statusEl.innerHTML =
    type === "loading" ? `<span class="spinner"></span>${msg}` : msg;
}

function hideStatus() {
  statusEl.hidden = true;
}

function updateUI() {
  const val = urlInput.value.trim();
  fetchBtn.disabled = !isTikTokURL(val);
  clearBtn.hidden = !val;
}

urlInput.addEventListener("input", () => {
  updateUI();
  previewEl.hidden = true;
  playerEl.hidden = true;
  iosGuideEl.hidden = true;
  hideStatus();
});

clearBtn.addEventListener("click", () => {
  urlInput.value = "";
  currentVideo = null;
  previewEl.hidden = true;
  playerEl.hidden = true;
  iosGuideEl.hidden = true;
  hideStatus();
  updateUI();
});

pasteBtn.addEventListener("click", async () => {
  try {
    const text = await navigator.clipboard.readText();
    if (text) {
      urlInput.value = text.trim();
      updateUI();
    }
  } catch {
    showStatus("Không đọc được clipboard. Hãy dán thủ công.", "error");
  }
});

fetchBtn.addEventListener("click", async () => {
  const url = urlInput.value.trim();
  if (!isTikTokURL(url)) return;

  showStatus("Đang lấy thông tin video...");
  previewEl.hidden = true;
  playerEl.hidden = true;
  iosGuideEl.hidden = true;
  fetchBtn.disabled = true;

  try {
    const res = await fetch(`/api/tiktok?url=${encodeURIComponent(url)}`);
    const data = await res.json();

    if (!res.ok) throw new Error(data.error || "Lỗi không xác định");

    currentVideo = data;
    renderPreview(data);
    hideStatus();

    if (isIOS()) {
      iosGuideEl.hidden = false;
    }
  } catch (err) {
    showStatus(err.message || "Lỗi kết nối", "error");
  } finally {
    fetchBtn.disabled = !isTikTokURL(urlInput.value.trim());
  }
});

function renderPreview(data) {
  $("cover").src = data.cover || "";
  $("author").textContent = data.author;
  $("username").textContent = data.username ? `@${data.username}` : "";
  $("title").textContent = data.title;
  $("badge").textContent =
    hdToggle.checked && data.hdplay ? "HD • Không logo" : "Không logo";
  previewEl.hidden = false;
}

async function saveViaShareAPI(videoUrl) {
  showStatus("Đang chuẩn bị video...");

  const res = await fetch(proxyDownloadUrl(videoUrl));
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.error || "Không tải được video");
  }

  const blob = await res.blob();
  const file = new File([blob], `tiktok_${currentVideo.id || "video"}.mp4`, {
    type: "video/mp4",
  });

  if (navigator.canShare && navigator.canShare({ files: [file] })) {
    await navigator.share({
      files: [file],
      title: currentVideo.title || "TikTok Video",
    });
    hideStatus();
    return true;
  }

  return false;
}

function openVideoInSafari(videoUrl) {
  window.open(videoUrl, "_blank", "noopener");
  iosGuideEl.hidden = false;
  iosGuideEl.scrollIntoView({ behavior: "smooth", block: "nearest" });
}

$("savePhotosBtn").addEventListener("click", async () => {
  const videoUrl = getVideoUrl();
  if (!videoUrl) {
    showStatus("Không tìm thấy link video", "error");
    return;
  }

  try {
    if (navigator.share) {
      const shared = await saveViaShareAPI(videoUrl);
      if (shared) return;
    }
  } catch (err) {
    if (err.name !== "AbortError") {
      console.warn("Share failed:", err);
    } else {
      hideStatus();
      return;
    }
  }

  openVideoInSafari(videoUrl);
  showStatus(
    'Đã mở video. Nhấn <strong>Chia sẻ</strong> ở dưới Safari → <strong>Lưu Video</strong>',
    "loading"
  );
});

$("openVideoBtn").addEventListener("click", () => {
  const videoUrl = getVideoUrl();
  if (!videoUrl) {
    showStatus("Không tìm thấy link video", "error");
    return;
  }

  openVideoInSafari(videoUrl);
  showStatus(
    'Video đã mở. Nhấn <strong>Chia sẻ</strong> (□↑) ở dưới → <strong>Lưu Video</strong>',
    "loading"
  );

  videoEl.src = videoUrl;
  playerEl.hidden = false;
});

hdToggle.addEventListener("change", () => {
  if (currentVideo) renderPreview(currentVideo);
});

updateUI();

if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/sw.js").catch(() => {});
}
