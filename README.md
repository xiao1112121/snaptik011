# SnapTik — Tải video TikTok iOS

Ứng dụng tải video TikTok **chất lượng cao (HD)** và **không có logo/watermark**.

## Không có MacBook?

Dùng phiên bản **Web/PWA** trong thư mục [`web/`](web/) — chạy trên iPhone qua Safari, **không cần Mac**, deploy miễn phí lên Vercel.

```powershell
cd web
npm install -g vercel
vercel
```

Xem hướng dẫn chi tiết: [web/README.md](web/README.md)

---

## Phiên bản iOS native (cần Mac + Xcode)


- Dán link TikTok (hỗ trợ `tiktok.com`, `vm.tiktok.com`, `vt.tiktok.com`)
- Lấy video không watermark qua API công khai
- Tùy chọn tải bản **HD** (độ phân giải cao nhất)
- Hiển thị thumbnail, tác giả, thời lượng
- Thanh tiến trình khi tải
- Lưu vào **Photos** (Thư viện ảnh)
- Giao diện tiếng Việt, dark theme

## Yêu cầu

- **macOS** với **Xcode 15+**
- **iOS 17+** (iPhone / iPad)
- Tài khoản Apple Developer (miễn phí để chạy trên máy thật)

## Cách build & chạy

1. Copy thư mục `SnapTik` sang Mac (hoặc mở trực tiếp nếu đã có Mac).
2. Mở `SnapTik/SnapTik.xcodeproj` bằng Xcode.
3. Chọn **Signing & Capabilities** → đặt **Team** (Apple ID của bạn).
4. Chọn iPhone Simulator hoặc thiết bị thật.
5. Nhấn **Run** (⌘R).

> **Lưu ý:** Simulator có thể gặp lỗi khi lưu video vào Photos. Nên test trên **iPhone thật**.

## Cách sử dụng

1. Mở TikTok → Chia sẻ video → **Sao chép liên kết**
2. Mở SnapTik → **Dán từ clipboard**
3. Bật **Chất lượng HD** (khuyến nghị)
4. Nhấn **Lấy thông tin video**
5. Nhấn **Tải & Lưu vào Thư viện ảnh**
6. Cho phép quyền truy cập Photos khi được hỏi

## Cấu trúc project

```
SnapTik/
├── SnapTikApp.swift          # Entry point
├── App/AppTheme.swift        # Màu sắc, theme
├── Models/                   # TikTokVideo, DownloadState
├── Services/
│   ├── TikTokVideoFetcher.swift   # Gọi API lấy link không watermark
│   ├── VideoDownloader.swift      # Tải file MP4
│   └── PhotoLibrarySaver.swift    # Lưu vào Photos
├── ViewModels/DownloadViewModel.swift
└── Views/                    # SwiftUI UI
```

## API sử dụng

App dùng endpoint công khai `tikwm.com` với tham số `hd=1` để lấy URL video không watermark:

```
GET https://www.tikwm.com/api/?url={tiktok_url}&hd=1
```

Trường `hdplay` = video HD không logo, `play` = chất lượng thường không logo.

## Lưu ý pháp lý

- Chỉ tải video **công khai** mà bạn có quyền sử dụng.
- Việc tải video có thể vi phạm **Điều khoản TikTok**.
- App **cá nhân / sideload** thường ổn; **App Store** có thể từ chối app downloader.
- Dịch vụ bên thứ ba (tikwm) có thể thay đổi hoặc ngừng hoạt động bất cứ lúc nào.

## Mở rộng (tùy chọn)

- Thêm **Share Extension** để tải trực tiếp từ menu Share của TikTok
- Thêm fetcher dự phòng nếu API chính lỗi
- Tải thêm **nhạc nền** (MP3) từ field `music` trong API response

## License

Dùng cho mục đích cá nhân / học tập.
