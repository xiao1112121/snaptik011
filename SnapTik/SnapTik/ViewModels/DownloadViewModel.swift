import Foundation
import Observation
import UIKit

@Observable
@MainActor
final class DownloadViewModel {
    var urlText = ""
    var state: DownloadState = .idle
    var preferHD = true

    private let fetcher: TikTokVideoFetching
    private let downloader = VideoDownloader()

    init(fetcher: TikTokVideoFetching = CompositeVideoFetcher()) {
        self.fetcher = fetcher
    }

    var canFetch: Bool {
        TikTokURLValidator.isValid(urlText) && !state.isBusy
    }

    var canDownload: Bool {
        if case .ready = state, !state.isBusy { return true }
        return false
    }

    func pasteFromClipboard() {
        if let text = UIPasteboard.general.string, !text.isEmpty {
            urlText = text
            state = .idle
        }
    }

    func fetchVideo() async {
        let normalized = TikTokURLValidator.normalize(urlText)
        guard TikTokURLValidator.isValid(normalized) else {
            state = .failure(TikTokError.invalidURL.localizedDescription ?? "Link không hợp lệ")
            return
        }

        state = .fetching

        do {
            let video = try await fetcher.fetchVideo(from: normalized)
            state = .ready(video)
        } catch let error as TikTokError {
            state = .failure(error.localizedDescription ?? "Lỗi không xác định")
        } catch {
            state = .failure(TikTokError.networkError(error).localizedDescription ?? "Lỗi mạng")
        }
    }

    func downloadAndSave() async {
        guard case .ready(let video) = state else { return }

        let downloadURL = preferHD ? video.bestDownloadURL : video.standardURL
        state = .downloading(progress: 0)

        let progressTask = Task {
            while !Task.isCancelled {
                if case .downloading = state {
                    state = .downloading(progress: downloader.progress)
                }
                try? await Task.sleep(for: .milliseconds(150))
            }
        }

        do {
            let localFile = try await downloader.download(from: downloadURL)
            progressTask.cancel()
            state = .saving
            try await PhotoLibrarySaver.saveVideo(at: localFile)
            state = .success
        } catch is CancellationError {
            progressTask.cancel()
            state = .ready(video)
        } catch let error as TikTokError {
            progressTask.cancel()
            state = .failure(error.localizedDescription ?? "Lỗi")
        } catch {
            progressTask.cancel()
            state = .failure(error.localizedDescription)
        }
    }

    func reset() {
        urlText = ""
        state = .idle
    }

    var downloadProgress: Double {
        if case .downloading(let progress) = state {
            return progress
        }
        return downloader.progress
    }
}
