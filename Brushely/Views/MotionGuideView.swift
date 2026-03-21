import SwiftUI

struct MotionGuideView: View {
    let status: MotionStatus

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.bMint.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: "hand.point.up.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.bMint)
            }

            Text(status == .idle
                 ? "Нажмите «Начать» и чистите перед камерой"
                 : status.label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Color.bText2)

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.bCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 12, y: 4)
        )
    }
}
