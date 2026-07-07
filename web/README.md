# SnapTik Web — Dùng trên iPhone KHÔNG CẦN Mac

Phiên bản **PWA** (Progressive Web App): mở bằng Safari trên iPhone, thêm vào Màn hình chính → dùng như app native.

## Cách 1: Deploy lên Vercel (miễn phí, khuyến nghị)

### Không cần Mac. Không bắt buộc cài Node.js trên máy.

#### Phương án A — Qua GitHub + Vercel (dễ nhất trên Windows)

1. Tạo tài khoản **GitHub** (github.com) và **Vercel** (vercel.com) — đều miễn phí
2. Tạo repo mới trên GitHub, upload thư mục `web/` (kéo thả file trên web GitHub cũng được)
3. Vào **vercel.com** → **Add New Project** → Import repo GitHub
4. **Root Directory** đặt là `web` (nếu upload cả project) hoặc để trống (nếu chỉ upload folder web)
5. Nhấn **Deploy** → đợi 1–2 phút → có link `https://xxx.vercel.app`

#### Phương án B — Qua Vercel CLI (cần Node.js)

```powershell
# Cài Node.js tại https://nodejs.org trước
npm install -g vercel
cd c:\Users\ADMIN\Desktop\snaptik\web
vercel
```

### Bước 4 — Dùng trên iPhone
1. Mở **Safari** → vào link Vercel vừa deploy
2. TikTok → Chia sẻ → **Sao chép liên kết**
3. SnapTik → **Dán từ clipboard** → **Lấy thông tin** → **Tải video**
4. Nhấn giữ video → **Lưu vào Ảnh**
5. (Tùy chọn) Safari → Chia sẻ → **Thêm vào Màn hình chính** → có icon app riêng

---

## Cách 2: Chạy thử trên máy tính (dev)

```powershell
cd c:\Users\ADMIN\Desktop\snaptik\web
npm run dev
```
Mở http://localhost:3000 — **lưu ý**: API proxy chỉ hoạt động đầy đủ khi deploy Vercel (local thiếu serverless function).

---

## Cách 3: Vẫn muốn app native iOS (Swift)?

Không có Mac thì có các lựa chọn:

| Cách | Chi phí | Ghi chú |
|------|---------|---------|
| **PWA (folder `web/`)** | Miễn phí | ✅ Khuyến nghị — dùng ngay trên iPhone |
| **Thuê Mac cloud** (MacinCloud, AWS EC2 Mac) | ~$1–4/giờ | Build app Swift trong Xcode từ xa |
| **GitHub Actions** (macOS runner) | Miễn phí (public repo) | Build IPA tự động trên cloud |
| **EAS Build** (Expo) | Miễn phí tier | Cần viết lại bằng React Native |

---

## So sánh PWA vs App native

| | PWA (web) | App Swift (SnapTik/) |
|---|---|---|
| Cần Mac | ❌ Không | ✅ Có |
| Cài trên iPhone | Safari → Thêm MH chính | Cần build + cài |
| Lưu vào Photos | Nhấn giữ video | Tự động |
| App Store | Không cần | Khó duyệt |
| Chất lượng HD | ✅ | ✅ |
| Không logo | ✅ | ✅ |

---

## Cấu trúc

```
web/
├── public/          # Giao diện (HTML/CSS/JS)
├── api/tiktok.js    # Proxy API (chạy trên Vercel)
└── vercel.json      # Cấu hình deploy
```
