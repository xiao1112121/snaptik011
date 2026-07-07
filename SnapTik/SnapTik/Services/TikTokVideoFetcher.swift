import Foundation

protocol TikTokVideoFetching {
    func fetchVideo(from urlString: String) async throws -> TikTokVideo
}

struct TikWMVideoFetcher: TikTokVideoFetching {
    private let session: URLSession
    private let baseURL = "https://www.tikwm.com/api/"

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchVideo(from urlString: String) async throws -> TikTokVideo {
        guard let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let apiURL = URL(string: "\(baseURL)?url=\(encoded)&hd=1") else {
            throw TikTokError.invalidURL
        }

        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.setValue("SnapTik/1.0 iOS", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 30

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw TikTokError.networkError(error)
        }

        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw TikTokError.apiError("Máy chủ trả về lỗi. Thử lại sau.")
        }

        let decoded = try JSONDecoder().decode(TikWMResponse.self, from: data)
        return try decoded.toVideo()
    }
}

/// Thử nhiều nguồn lấy video theo thứ tự ưu tiên.
struct CompositeVideoFetcher: TikTokVideoFetching {
    private let fetchers: [TikTokVideoFetching]

    init(fetchers: [TikTokVideoFetching] = [TikWMVideoFetcher()]) {
        self.fetchers = fetchers
    }

    func fetchVideo(from urlString: String) async throws -> TikTokVideo {
        var lastError: Error = TikTokError.apiError("Không thể lấy video")

        for fetcher in fetchers {
            do {
                return try await fetcher.fetchVideo(from: urlString)
            } catch {
                lastError = error
            }
        }

        throw lastError
    }
}

enum TikTokURLValidator {
    private static let patterns = [
        "tiktok.com",
        "vm.tiktok.com",
        "vt.tiktok.com",
        "www.tiktok.com"
    ]

    static func isValid(_ url: String) -> Bool {
        let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return patterns.contains { trimmed.lowercased().contains($0) }
    }

    static func normalize(_ url: String) -> String {
        url.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
