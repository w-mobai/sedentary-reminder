import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var reminder: ReminderManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                LeafMark(size: 32)
                VStack(alignment: .leading, spacing: 1) {
                    Text(reminder.phase.title).font(.system(size: 13, weight: .bold))
                    Text(reminder.nextReminderText)
                        .font(.system(size: 10))
                        .foregroundStyle(MoveTheme.inkMuted)
                }
                Spacer()
            }

            HStack(alignment: .firstTextBaseline) {
                Text(reminder.clockText)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                Spacer()
                Text("第 \(reminder.completedBreaks + 1) 轮")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(MoveTheme.inkMuted)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(MoveTheme.forest.opacity(0.12))
                    Capsule()
                        .fill(MoveTheme.forest)
                        .frame(width: max(5, proxy.size.width * reminder.progress))
                }
            }
            .frame(height: 5)
            .animation(.linear(duration: 0.8), value: reminder.progress)

            HStack(spacing: 10) {
                Button(reminder.isPaused ? "继续" : "暂停") { reminder.togglePause() }
                    .buttonStyle(MenuBarActionButtonStyle())
                Button("活动") { reminder.skipToBreak() }
                    .buttonStyle(MenuBarActionButtonStyle())
                Spacer()
                Button("打开主页") {
                    NSApp.setActivationPolicy(.regular)
                    openWindow(id: "dashboard")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        NSApp.activate(ignoringOtherApps: true)
                        NSRunningApplication.current.activate(options: [.activateAllWindows])
                        NSApp.windows.first(where: { $0.canBecomeMain })?.makeKeyAndOrderFront(nil)
                    }
                }
                .buttonStyle(MenuBarActionButtonStyle(prominent: true))
            }

            Divider()
                .overlay(MoveTheme.line)
            Button("退出 Move Ease") { NSApp.terminate(nil) }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(MoveTheme.inkMuted)
        }
        .padding(18)
        .frame(width: 300)
        .background(MoveTheme.cream)
        .foregroundStyle(MoveTheme.forest)
        .preferredColorScheme(.light)
    }
}

private struct MenuBarActionButtonStyle: ButtonStyle {
    var prominent = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(prominent ? Color.white : MoveTheme.forest)
            .padding(.horizontal, 11)
            .frame(height: 28)
            .background(prominent ? MoveTheme.forest : MoveTheme.mint)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}
