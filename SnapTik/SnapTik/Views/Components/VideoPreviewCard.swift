import SwiftUI

struct VideoPreviewCard: View {
    let video: TikTokVideo
    let preferHD: Bool
    @State private var showShareSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                thumbnail
                VStack(alignment: .leading, spacing: 6) {
                    Text(video.authorName)
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                    if !video.authorUsername.isEmpty {
                        Text("@\(video.authorUsername)")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    HStack(spacing: 8) {
                        qualityBadge
                        if video.duration > 0 {
                            Label(formatDuration(video.duration), systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
                }
                Spacer(minLength: 0)
            }

            Text(video.title)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(2)
        }
        .padding(AppTheme.padding)
        .cardStyle()
        .contextMenu {
            Button(action: { showShareSheet = true }) {
                Label("Chia sẻ", systemImage: "square.and.arrow.up")
            }
            Button(action: { UIPasteboard.general.string = video.bestDownloadURL.absoluteString }) {
                Label("Sao chép link", systemImage: "doc.on.doc")
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: [video.bestDownloadURL])
        }
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let coverURL = video.coverURL {
            AsyncImage(url: coverURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                default:
                    placeholder
                }
            }
            .frame(width: 72, height: 96)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            placeholder
                .frame(width: 72, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var placeholder: some View {
        ZStack {
            AppTheme.surfaceElevated
            Image(systemName: "play.rectangle.fill")
                .font(.title2)
                .foregroundStyle(AppTheme.accent)
        }
    }

    private var qualityBadge: some View {
        Text(preferHD && video.isHD ? "HD • Không logo" : "Không logo")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppTheme.accent.opacity(0.2))
            .foregroundStyle(AppTheme.accent)
            .clipShape(Capsule())
    }

    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
