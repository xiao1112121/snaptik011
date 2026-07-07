import SwiftUI

struct ProgressOverlay: View {
    let title: String
    let progress: Double?

    var body: some View {
        VStack(spacing: 16) {
            if let progress {
                ProgressView(value: progress)
                    .tint(AppTheme.accent)
                    .scaleEffect(y: 2)
                Text("\(Int(progress * 100))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(AppTheme.textSecondary)
            } else {
                ProgressView()
                    .tint(AppTheme.accent)
                    .scaleEffect(1.2)
            }
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

struct SuccessBanner: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(AppTheme.success)
            VStack(alignment: .leading, spacing: 2) {
                Text("Đã lưu vào Thư viện ảnh!")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)
                Text("Mở app Ảnh để xem video")
                    .font(.caption)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
            Button("OK", action: onDismiss)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.accent)
        }
        .padding(AppTheme.padding)
        .background(AppTheme.success.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.success.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AppTheme.error)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppTheme.textPrimary)
            Spacer(minLength: 0)
        }
        .padding(AppTheme.padding)
        .background(AppTheme.error.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(AppTheme.error.opacity(0.3), lineWidth: 1)
        )
    }
}
