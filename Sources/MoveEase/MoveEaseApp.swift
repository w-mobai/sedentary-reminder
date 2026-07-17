import SwiftUI
import AppKit

@main
struct MoveEaseApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var reminder = ReminderManager.shared

    var body: some Scene {
        Window("Move Ease", id: "dashboard") {
            DashboardView()
                .environmentObject(reminder)
                .frame(minWidth: 920, minHeight: 650)
                .preferredColorScheme(.light)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unifiedCompact)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandMenu("计时") {
                Button(reminder.isPaused ? "继续" : "暂停") {
                    reminder.togglePause()
                }
                .keyboardShortcut(.space, modifiers: [])

                Button("重新开始") { reminder.restart() }
                    .keyboardShortcut("r", modifiers: .command)
            }
        }

        MenuBarExtra {
            MenuBarView()
                .environmentObject(reminder)
        } label: {
            Label(reminder.menuBarTitle, systemImage: reminder.phase.menuBarIcon)
        }
        .menuBarExtraStyle(.window)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillClose(_:)),
            name: NSWindow.willCloseNotification,
            object: nil
        )
        ReminderManager.shared.start()
        ReminderManager.shared.requestNotificationPermission()
    }

    @objc private func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow,
              window.title == "Move Ease" else { return }
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
