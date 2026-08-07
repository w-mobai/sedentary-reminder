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
    private var screenParametersObserver: NSObjectProtocol?
    private var wakeObserver: NSObjectProtocol?
    private var refreshTask: Task<Void, Never>?

    init(manager: ReminderManager) {
        self.manager = manager
        screenParametersObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.schedulePanelRefresh(after: 0.5)
            }
        }
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.schedulePanelRefresh(after: 1.5)
            }
        }
    }

    deinit {
        if let screenParametersObserver {
            NotificationCenter.default.removeObserver(screenParametersObserver)
        }
        if let wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
        }
        refreshTask?.cancel()
    }

    func show() {
        guard panels.isEmpty else {
            panels.forEach { $0.orderFrontRegardless() }
            schedulePanelRefresh(after: 1.5)
            return
        }

        rebuildPanels(requestAttention: true)
        schedulePanelRefresh(after: 1.5)
    }

    func dismiss() {
        refreshTask?.cancel()
        refreshTask = nil
        closePanels()
    }

    private func rebuildPanels(requestAttention: Bool) {
        guard let manager else { return }
        closePanels()

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
        if requestAttention {
            NSApp.requestUserAttention(.criticalRequest)
        }
    }

    private func schedulePanelRefresh(after delay: TimeInterval) {
        guard !panels.isEmpty else { return }
        refreshTask?.cancel()
        refreshTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled, let self, !self.panels.isEmpty else { return }
            self.rebuildPanels(requestAttention: false)
        }
    }

    private func closePanels() {
        panels.forEach {
            $0.orderOut(nil)
            $0.close()
        }
        panels.removeAll()
    }
}
