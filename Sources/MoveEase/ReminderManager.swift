import Foundation
import SwiftUI
import UserNotifications

enum ReminderPhase: String {
    case focus
    case moving

    var title: String { self == .focus ? "专注中" : "活动一下" }
    var eyebrow: String { self == .focus ? "保持节奏" : "身体在等你" }
    var menuBarIcon: String { self == .focus ? "leaf.fill" : "figure.walk" }
}

@MainActor
final class ReminderManager: ObservableObject {
    static let shared = ReminderManager()

    @Published private(set) var phase: ReminderPhase = .focus
    @Published private(set) var remaining: TimeInterval = 45 * 60
    @Published private(set) var isPaused = false
    @Published private(set) var completedBreaks = 0
    @Published private(set) var sessionStartedAt = Date()

    @Published var focusMinutes: Double {
        didSet { UserDefaults.standard.set(focusMinutes, forKey: "focusMinutes") }
    }
    @Published var breakMinutes: Double {
        didSet { UserDefaults.standard.set(breakMinutes, forKey: "breakMinutes") }
    }
    @Published var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled") }
    }
    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }

    private var deadline = Date().addingTimeInterval(45 * 60)
    private var pausedRemaining: TimeInterval?
    private var timer: Timer?
    private lazy var overlay = ReminderOverlayController(manager: self)

    private init() {
        let defaults = UserDefaults.standard
        focusMinutes = defaults.object(forKey: "focusMinutes") == nil ? 45 : defaults.double(forKey: "focusMinutes")
        breakMinutes = defaults.object(forKey: "breakMinutes") == nil ? 5 : defaults.double(forKey: "breakMinutes")
        soundEnabled = defaults.object(forKey: "soundEnabled") == nil ? true : defaults.bool(forKey: "soundEnabled")
        notificationsEnabled = defaults.object(forKey: "notificationsEnabled") == nil ? true : defaults.bool(forKey: "notificationsEnabled")
        remaining = focusMinutes * 60
        deadline = Date().addingTimeInterval(remaining)
    }

    var totalDuration: TimeInterval {
        (phase == .focus ? focusMinutes : breakMinutes) * 60
    }

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return max(0, min(1, 1 - remaining / totalDuration))
    }

    var clockText: String {
        let seconds = max(0, Int(remaining.rounded(.up)))
        return String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    var menuBarTitle: String { isPaused ? "已暂停" : clockText }

    var nextReminderText: String {
        if isPaused { return "计时器已暂停" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return phase == .focus
            ? "\(formatter.string(from: deadline)) 提醒起身"
            : "\(formatter.string(from: deadline)) 开始下一轮"
    }

    func start() {
        guard timer == nil else { return }
        restartTimer(for: .focus)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func requestNotificationPermission() {
        notificationCenter?.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func togglePause() {
        if isPaused {
            deadline = Date().addingTimeInterval(pausedRemaining ?? remaining)
            pausedRemaining = nil
            isPaused = false
        } else {
            pausedRemaining = remaining
            isPaused = true
        }
    }

    func restart() {
        overlay.dismiss()
        completedBreaks = 0
        restartTimer(for: .focus)
    }

    func skipToBreak() {
        beginBreak()
    }

    func startThreeSecondTest() {
        overlay.dismiss()
        phase = .focus
        isPaused = false
        pausedRemaining = nil
        remaining = 3
        deadline = Date().addingTimeInterval(3)
    }

    func finishBreak() {
        overlay.dismiss()
        completedBreaks += 1
        restartTimer(for: .focus)
        sendActivityCompleteNotification()
    }

    func snooze(minutes: Int = 5) {
        overlay.dismiss()
        phase = .focus
        remaining = TimeInterval(minutes * 60)
        deadline = Date().addingTimeInterval(remaining)
        pausedRemaining = nil
        isPaused = false
    }

    private func tick() {
        guard !isPaused else { return }
        remaining = max(0, deadline.timeIntervalSinceNow)
        guard remaining <= 0 else { return }

        if phase == .focus { beginBreak() }
    }

    private func beginBreak() {
        restartTimer(for: .moving)
        overlay.show()
        sendSystemNotification()
    }

    private func restartTimer(for newPhase: ReminderPhase) {
        phase = newPhase
        isPaused = false
        pausedRemaining = nil
        remaining = totalDuration
        deadline = Date().addingTimeInterval(remaining)
        if newPhase == .focus { sessionStartedAt = Date() }
    }

    private func sendSystemNotification() {
        guard notificationsEnabled, let notificationCenter else { return }
        let content = UNMutableNotificationContent()
        content.title = "该起身活动啦"
        content.body = "离开屏幕 \(Int(breakMinutes)) 分钟，走一走、喝口水，让身体松一松。"
        if soundEnabled { content.sound = .default }
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        notificationCenter.add(request)
    }

    private func sendActivityCompleteNotification() {
        guard notificationsEnabled, let notificationCenter else { return }
        let content = UNMutableNotificationContent()
        content.title = "活动完成，回来继续吧"
        content.body = "下一轮 \(Int(focusMinutes)) 分钟专注已经开始。"
        if soundEnabled { content.sound = .default }
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        notificationCenter.add(request)
    }

    /// Xcode runs Swift packages as standalone executables rather than app bundles.
    /// UserNotifications aborts when no app bundle is available, so notifications
    /// are enabled only for the packaged Move Ease.app build.
    private var notificationCenter: UNUserNotificationCenter? {
        guard Bundle.main.bundleURL.pathExtension == "app" else { return nil }
        return UNUserNotificationCenter.current()
    }
}
