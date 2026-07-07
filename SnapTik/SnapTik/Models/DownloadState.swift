import Foundation

enum DownloadState: Equatable {
    case idle
    case fetching
    case ready(TikTokVideo)
    case downloading(progress: Double)
    case saving
    case success
    case failure(String)

    var isBusy: Bool {
        switch self {
        case .fetching, .downloading, .saving:
            return true
        default:
            return false
        }
    }
}
