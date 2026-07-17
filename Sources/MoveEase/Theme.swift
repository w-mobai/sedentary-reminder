import SwiftUI
import AppKit

enum MoveTheme {
    static let forest = Color(red: 15/255, green: 62/255, blue: 23/255)
    static let forestSoft = Color(red: 23/255, green: 62/255, blue: 30/255)
    static let mint = Color(red: 225/255, green: 244/255, blue: 223/255)
    static let cream = Color(red: 255/255, green: 254/255, blue: 252/255)
    static let lime = Color(red: 195/255, green: 239/255, blue: 132/255)
    static let inkMuted = Color(red: 78/255, green: 103/255, blue: 82/255)
    static let line = Color(red: 15/255, green: 62/255, blue: 23/255).opacity(0.1)
}

struct SoftCard: ViewModifier {
    var padding: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(MoveTheme.cream.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(MoveTheme.line, lineWidth: 1)
            }
            .shadow(color: MoveTheme.forest.opacity(0.07), radius: 22, y: 10)
    }
}

extension View {
    func softCard(padding: CGFloat = 24) -> some View {
        modifier(SoftCard(padding: padding))
    }
}

struct LeafMark: View {
    var size: CGFloat = 38

    var body: some View {
        Image(nsImage: NSApplication.shared.applicationIconImage)
            .resizable()
            .interpolation(.high)
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}
