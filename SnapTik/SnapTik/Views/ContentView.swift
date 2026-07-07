import SwiftUI

struct ContentView: View {
    @State private var viewModel = DownloadViewModel()
    @FocusState private var urlFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    urlInputSection
                    optionsSection
                    actionButtons
                    statusSection
                }
                .padding(.horizontal, AppTheme.padding)
                .padding(.bottom, 32)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.accent, AppTheme.accentSecondary.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            .padding(.top, 8)

            Text("SnapTik")
                .font(.largeTitle.bold())
                .foregroundStyle(AppTheme.textPrimary)

            Text("Tải video TikTok chất lượng cao, không logo")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var urlInputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dán link TikTok")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.textSecondary)

            HStack(spacing: 10) {
                TextField("https://www.tiktok.com/@user/video/...", text: $viewModel.urlText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(AppTheme.textPrimary)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .focused($urlFieldFocused)
                    .onChange(of: viewModel.urlText) { _, _ in
                        if case .failure = viewModel.state { viewModel.state = .idle }
                        if case .success = viewModel.state { viewModel.state = .idle }
                    }

                if !viewModel.urlText.isEmpty {
                    Button {
                        viewModel.urlText = ""
                        viewModel.state = .idle
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
            .padding(14)
            .background(AppTheme.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        urlFieldFocused ? AppTheme.accent.opacity(0.5) : Color.white.opacity(0.06),
                        lineWidth: 1
                    )
            )

            Button {
                viewModel.pasteFromClipboard()
            } label: {
                Label("Dán từ clipboard", systemImage: "doc.on.clipboard")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.accentSecondary)
            }
        }
    }

    private var optionsSection: some View {
        Toggle(isOn: $viewModel.preferHD) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Chất lượng HD")
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Tải bản không watermark, độ phân giải cao nhất")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .tint(AppTheme.accent)
        .padding(AppTheme.padding)
        .cardStyle()
    }

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                urlFieldFocused = false
                Task { await viewModel.fetchVideo() }
            } label: {
                HStack {
                    if case .fetching = viewModel.state {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: "magnifyingglass")
                        Text("Lấy thông tin video")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(viewModel.canFetch ? AppTheme.accent : AppTheme.accent.opacity(0.4))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!viewModel.canFetch)

            if viewModel.canDownload {
                Button {
                    Task { await viewModel.downloadAndSave() }
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("Tải & Lưu vào Thư viện ảnh")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.accentSecondary, AppTheme.accentSecondary.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(AppTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    @ViewBuilder
    private var statusSection: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()

        case .fetching:
            ProgressOverlay(title: "Đang lấy thông tin video...", progress: nil)

        case .ready(let video):
            VideoPreviewCard(video: video, preferHD: viewModel.preferHD)

        case .downloading:
            ProgressOverlay(title: "Đang tải video...", progress: viewModel.downloadProgress)

        case .saving:
            ProgressOverlay(title: "Đang lưu vào Thư viện ảnh...", progress: nil)

        case .success:
            SuccessBanner { viewModel.reset() }

        case .failure(let message):
            ErrorBanner(message: message)
        }
    }
}

#Preview {
    ContentView()
}
