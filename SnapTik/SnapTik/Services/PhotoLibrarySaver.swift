import Photos
import UIKit

enum PhotoLibrarySaver {
    static func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status == .authorized || status == .limited)
            }
        }
    }

    static func saveVideo(at fileURL: URL) async throws {
        let authorized = await requestAuthorization()
        guard authorized else {
            throw TikTokError.photoPermissionDenied
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else {
                    let message = error?.localizedDescription ?? "Unknown error"
                    continuation.resume(throwing: TikTokError.saveFailed(message))
                }
            }
        }

        try? FileManager.default.removeItem(at: fileURL)
    }
}
