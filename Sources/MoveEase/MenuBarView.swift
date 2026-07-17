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
                    Text(reminder.nextReminderText).font(.system(size: 10)).foregroundStyle(.secondary)
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

            ProgressView(value: reminder.progress).tint(MoveTheme.forest)

            HStack(spacing: 10) {
                Button(reminder.isPaused ? "继续" : "暂停") { reminder.togglePause() }
                Button("活动") { reminder.skipToBreak() }
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
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Divider()
            Button("退出 Move Ease") { NSApp.terminate(nil) }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(width: 300)
        .foregroundStyle(MoveTheme.forest)
    }
}
