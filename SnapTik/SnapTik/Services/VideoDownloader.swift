import Foundation

@MainActor
final class VideoDownloader: NSObject, ObservableObject {
    @Published var progress: Double = 0

    private var downloadTask: URLSessionDownloadTask?
    private var continuation: CheckedContinuation<URL, Error>?

    func download(from url: URL) async throws -> URL {
        progress = 0

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 120
            config.timeoutIntervalForResource = 300
            let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)

            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
            request.setValue("https://www.tiktok.com/", forHTTPHeaderField: "Referer")
            request.setValue("*/*", forHTTPHeaderField: "Accept")

            downloadTask = session.downloadTask(with: request)
            downloadTask?.resume()
        }
    }

    func cancel() {
        downloadTask?.cancel()
        continuation?.resume(throwing: CancellationError())
        continuation = nil
    }
}

extension VideoDownloader: URLSessionDownloadDelegate {
    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        let tempDir = FileManager.default.temporaryDirectory
        let dest = tempDir.appendingPathComponent(UUID().uuidString + ".mp4")

        do {
            if FileManager.default.fileExists(atPath: dest.path) {
                try FileManager.default.removeItem(at: dest)
            }
            try FileManager.default.moveItem(at: location, to: dest)
            Task { @MainActor in
                self.continuation?.resume(returning: dest)
                self.continuation = nil
            }
        } catch {
            Task { @MainActor in
                self.continuation?.resume(throwing: TikTokError.downloadFailed)
                self.continuation = nil
            }
        }
    }

    nonisolated func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let value = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        Task { @MainActor in
            self.progress = value
        }
    }

    nonisolated func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        guard let error else { return }
        Task { @MainActor in
            if self.continuation != nil {
                self.continuation?.resume(throwing: error)
                self.continuation = nil
            }
        }
    }
}
