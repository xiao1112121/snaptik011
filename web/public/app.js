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
const directLink = $("directLink");

let currentVideo = null;

const isTikTokURL = (url) =>
  /tiktok\.com|vm\.tiktok\.com|vt\.tiktok\.com/i.test(url);

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
  hideStatus();
});

clearBtn.addEventListener("click", () => {
  urlInput.value = "";
  currentVideo = null;
  previewEl.hidden = true;
  playerEl.hidden = true;
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
  fetchBtn.disabled = true;

  try {
    const res = await fetch(`/api/tiktok?url=${encodeURIComponent(url)}`);
    const data = await res.json();

    if (!res.ok) throw new Error(data.error || "Lỗi không xác định");

    currentVideo = data;
    renderPreview(data);
    hideStatus();
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

$("downloadBtn").addEventListener("click", () => {
  if (!currentVideo) return;

  const useHD = hdToggle.checked && currentVideo.hdplay;
  const videoUrl = useHD ? currentVideo.hdplay : currentVideo.play;

  if (!videoUrl) {
    showStatus("Không tìm thấy link video", "error");
    return;
  }

  videoEl.src = videoUrl;
  directLink.href = videoUrl;
  playerEl.hidden = false;
  playerEl.scrollIntoView({ behavior: "smooth", block: "nearest" });
});

hdToggle.addEventListener("change", () => {
  if (currentVideo) renderPreview(currentVideo);
});

updateUI();

if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/sw.js").catch(() => {});
}
