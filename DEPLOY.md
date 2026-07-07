# Hướng dẫn đẩy code lên GitHub

Repo của bạn: https://github.com/xiao1112121/snaptik011

Máy hiện **chưa cài Git**, nên upload qua web GitHub là cách nhanh nhất.

---

## Bước 1 — Upload code lên GitHub

1. Mở https://github.com/xiao1112121/snaptik011
2. Nhấn **Add file** → **Upload files**
3. Kéo thả **toàn bộ nội dung** trong thư mục `snaptik` (gồm `web/`, `SnapTik/`, `README.md`)
4. Commit message: `Initial commit - SnapTik PWA`
5. Nhấn **Commit changes**

---

## Bước 2 — Deploy lên Vercel

1. Vào https://vercel.com → đăng nhập bằng GitHub
2. **Add New Project** → chọn repo `snaptik011`
3. Cấu hình quan trọng:
   - **Root Directory** → nhấn **Edit** → chọn `web`
   - Framework Preset: **Other**
4. Nhấn **Deploy**
5. Đợi 1–2 phút → có link `https://snaptik011-xxx.vercel.app`

---

## Bước 3 — Dùng trên iPhone

1. Safari → mở link Vercel
2. TikTok → Chia sẻ → Sao chép liên kết
3. SnapTik → Dán → Lấy thông tin → Tải video
4. Nhấn giữ video → **Lưu vào Ảnh**
5. Safari → Chia sẻ → **Thêm vào Màn hình chính** (tùy chọn)

---

## (Tùy chọn) Cài Git để push từ máy sau này

1. Tải Git: https://git-scm.com/download/win
2. Cài xong, mở PowerShell:

```powershell
cd c:\Users\ADMIN\Desktop\snaptik
git init
git add .
git commit -m "Initial commit - SnapTik PWA"
git branch -M main
git remote add origin https://github.com/xiao1112121/snaptik011.git
git push -u origin main
```

Lần đầu push sẽ hỏi đăng nhập GitHub.
