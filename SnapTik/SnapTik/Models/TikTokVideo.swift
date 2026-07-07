import Foundation

struct TikTokVideo: Identifiable, Equatable {
    let id: String
    let title: String
    let authorName: String
    let authorUsername: String
    let coverURL: URL?
    let standardURL: URL
    let hdURL: URL?
    let duration: Int

    var bestDownloadURL: URL {
        hdURL ?? standardURL
    }

    var isHD: Bool {
        hdURL != nil
    }
}

struct TikWMResponse: Decodable {
    let code: Int
    let msg: String?
    let data: TikWMData?

    struct TikWMData: Decodable {
        let id: String?
        let title: String?
        let cover: String?
        let play: String?
        let hdplay: String?
        let wmplay: String?
        let duration: Int?
        let author: Author?

        struct Author: Decodable {
            let unique_id: String?
            let nickname: String?
        }
    }

    func toVideo() throws -> TikTokVideo {
        guard code == 0, let data else {
            throw TikTokError.apiError(msg ?? "Không thể lấy thông tin video")
        }

        guard let play = data.play, let standardURL = URL(string: play) else {
            throw TikTokError.invalidVideoURL
        }

        let hdURL = data.hdplay.flatMap { URL(string: $0) }
        let coverURL = data.cover.flatMap { URL(string: $0) }

        return TikTokVideo(
            id: data.id ?? UUID().uuidString,
            title: data.title ?? "TikTok Video",
            authorName: data.author?.nickname ?? "Unknown",
            authorUsername: data.author?.unique_id ?? "",
            coverURL: coverURL,
            standardURL: standardURL,
            hdURL: hdURL,
            duration: data.duration ?? 0
        )
    }
}

enum TikTokError: LocalizedError {
    case invalidURL
    case invalidVideoURL
    case apiError(String)
    case networkError(Error)
    case downloadFailed
    case saveFailed(String)
    case photoPermissionDenied

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Link TikTok không hợp lệ. Vui lòng kiểm tra lại."
        case .invalidVideoURL:
            return "Không tìm thấy URL video để tải."
        case .apiError(let message):
            return message
        case .networkError:
            return "Lỗi kết nối mạng. Kiểm tra internet và thử lại."
        case .downloadFailed:
            return "Tải video thất bại. Vui lòng thử lại."
        case .saveFailed(let message):
            return "Lưu video thất bại: \(message)"
        case .photoPermissionDenied:
            return "Cần quyền truy cập Thư viện ảnh để lưu video."
        }
    }
}
