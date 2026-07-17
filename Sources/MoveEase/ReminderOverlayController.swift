import AppKit
import SwiftUI

@MainActor
private final class ReminderBlockingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

@MainActor
final class ReminderOverlayController {
    private weak var manager: ReminderManager?
    private var panels: [NSPanel] = []

    init(manager: ReminderManager) {
        self.manager = manager
    }

    func show() {
        guard let manager else { return }
        guard panels.isEmpty else {
            panels.forEach { $0.orderFrontRegardless() }
            return
        }

        let screens = NSScreen.screens
        guard let primaryScreen = NSScreen.main ?? screens.first else { return }
        let orderedScreens = screens.filter { $0 !== primaryScreen } + [primaryScreen]
        var primaryPanel: NSPanel?

        for screen in orderedScreens {
            let panel = ReminderBlockingPanel(
                contentRect: screen.frame,
                styleMask: [.borderless],
                backing: .buffered,
                defer: false,
                screen: screen
            )
            panel.level = .screenSaver
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.hasShadow = false
            panel.hidesOnDeactivate = false
            panel.ignoresMouseEvents = false
            panel.acceptsMouseMovedEvents = true
            panel.isReleasedWhenClosed = false
            panel.setFrame(screen.frame, display: true)

            if screen === primaryScreen {
                panel.contentView = NSHostingView(
                    rootView: BlockingReminderScreen()
                        .environmentObject(manager)
                )
                primaryPanel = panel
            } else {
                panel.contentView = NSHostingView(rootView: SecondaryScreenMask())
            }

            panels.append(panel)
            panel.orderFrontRegardless()
        }

        NSApp.activate(ignoringOtherApps: true)
        primaryPanel?.makeKeyAndOrderFront(nil)
        NSApp.requestUserAttention(.criticalRequest)
    }

    func dismiss() {
        panels.forEach {
            $0.orderOut(nil)
            $0.close()
        }
        panels.removeAll()
    }
}
