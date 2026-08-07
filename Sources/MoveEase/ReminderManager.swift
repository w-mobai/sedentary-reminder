import Foundation
import SwiftUI

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
    private var deadline = Date().addingTimeInterval(45 * 60)
    private var pausedRemaining: TimeInterval?
    private var timer: Timer?
    private lazy var overlay = ReminderOverlayController(manager: self)

    private init() {
        let defaults = UserDefaults.standard
        focusMinutes = defaults.object(forKey: "focusMinutes") == nil ? 45 : defaults.double(forKey: "focusMinutes")
        breakMinutes = defaults.object(forKey: "breakMinutes") == nil ? 5 : defaults.double(forKey: "breakMinutes")
        remaining = focusMinutes * 60
        deadline = Date().addingTimeInterval(remaining)
        restoreDailyBreakCount()
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
        resetDailyBreakCountIfNeeded()
        completedBreaks += 1
        saveDailyBreakCount()
        restartTimer(for: .focus)
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
        resetDailyBreakCountIfNeeded()
        guard !isPaused else { return }
        remaining = max(0, deadline.timeIntervalSinceNow)
        guard remaining <= 0 else { return }

        if phase == .focus { beginBreak() }
    }

    private func beginBreak() {
        restartTimer(for: .moving)
        overlay.show()
    }

    private func restartTimer(for newPhase: ReminderPhase) {
        phase = newPhase
        isPaused = false
        pausedRemaining = nil
        remaining = totalDuration
        deadline = Date().addingTimeInterval(remaining)
        if newPhase == .focus { sessionStartedAt = Date() }
    }

    private func resetDailyBreakCountIfNeeded(now: Date = Date()) {
        let defaults = UserDefaults.standard
        let savedDate = defaults.object(forKey: "completedBreaksDate") as? Date
        let isToday = savedDate.map {
            Calendar.autoupdatingCurrent.isDate($0, inSameDayAs: now)
        } ?? false

        guard !isToday else { return }

        completedBreaks = 0
        defaults.set(0, forKey: "completedBreaks")
        defaults.set(now, forKey: "completedBreaksDate")
    }

    private func restoreDailyBreakCount(now: Date = Date()) {
        resetDailyBreakCountIfNeeded(now: now)
        completedBreaks = UserDefaults.standard.integer(forKey: "completedBreaks")
    }

    private func saveDailyBreakCount(now: Date = Date()) {
        let defaults = UserDefaults.standard
        defaults.set(completedBreaks, forKey: "completedBreaks")
        defaults.set(now, forKey: "completedBreaksDate")
    }

}
