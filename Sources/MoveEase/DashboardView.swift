import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var reminder: ReminderManager
    @State private var selectedNav = 0

    var body: some View {
        ZStack {
            MoveTheme.cream.ignoresSafeArea()
            Circle()
                .fill(MoveTheme.mint.opacity(0.7))
                .frame(width: 520, height: 520)
                .blur(radius: 2)
                .offset(x: 430, y: -310)

            HStack(spacing: 0) {
                sidebar
                    .frame(width: 220)
                Divider().overlay(MoveTheme.line)
                content
            }
        }
        .foregroundStyle(MoveTheme.forest)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 28) {
            HStack(spacing: 12) {
                LeafMark(size: 40)
                VStack(alignment: .leading, spacing: 0) {
                    Text("Move Ease")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Text("轻松动一动")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(MoveTheme.inkMuted)
                }
            }

            VStack(spacing: 8) {
                navButton("今日节奏", icon: "circle.grid.2x2.fill", index: 0)
                navButton("提醒设置", icon: "slider.horizontal.3", index: 1)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 22))
                    .foregroundStyle(MoveTheme.lime)
                Text("照顾身体，\n也是工作的一部分。")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .lineSpacing(5)
                Text("今天已经完成 \(reminder.completedBreaks) 次活动")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(MoveTheme.inkMuted)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MoveTheme.forest)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .padding(24)
        .background(MoveTheme.mint.opacity(0.36))
    }

    private func navButton(_ title: String, icon: String, index: Int) -> some View {
        Button {
            withAnimation(.easeOut(duration: 0.2)) { selectedNav = index }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon).frame(width: 18)
                Text(title).font(.system(size: 14, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
            .background(selectedNav == index ? MoveTheme.forest : .clear)
            .foregroundStyle(selectedNav == index ? Color.white : MoveTheme.forest)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private var content: some View {
        Group {
            if selectedNav == 0 { TodayView() }
            else { SettingsView() }
        }
        .padding(36)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct TodayView: View {
    @EnvironmentObject private var reminder: ReminderManager

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting)
                        .font(.system(size: 31, weight: .bold, design: .rounded))
                    Text("给专注一点边界，也给身体一点空间。")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(MoveTheme.inkMuted)
                }
                Spacer()
                statusPill
            }

            HStack(spacing: 14) {
                statCard(icon: "figure.walk", value: "\(reminder.completedBreaks)", label: "今日活动")
                statCard(icon: "clock.arrow.circlepath", value: "\(Int(reminder.focusMinutes))", label: "分钟一轮")
            }
            .frame(height: 78)

            timerCard

            HStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .foregroundStyle(MoveTheme.forest)
                Text("下一步")
                    .font(.system(size: 12, weight: .bold))
                    .textCase(.uppercase)
                Text(reminder.nextReminderText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(MoveTheme.inkMuted)
                Spacer()
                Button {
                    reminder.startThreeSecondTest()
                } label: {
                    Label("3 秒测试", systemImage: "bolt.fill")
                        .padding(.horizontal, 12)
                        .frame(height: 30)
                        .background(MoveTheme.mint)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(MoveTheme.forest)

                Button("立即活动") { reminder.skipToBreak() }
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(MoveTheme.forest)
            }
            .softCard(padding: 18)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 11 { return "早上好，慢慢进入状态" }
        if hour < 18 { return "下午好，保持松弛与专注" }
        return "晚上好，别忘了舒展身体"
    }

    private var statusPill: some View {
        HStack(spacing: 8) {
            Circle().fill(reminder.isPaused ? Color.orange : MoveTheme.lime).frame(width: 8, height: 8)
            Text(reminder.isPaused ? "已暂停" : reminder.phase.title)
                .font(.system(size: 12, weight: .bold))
        }
        .padding(.horizontal, 14)
        .frame(height: 34)
        .background(MoveTheme.forest)
        .foregroundStyle(.white)
        .clipShape(Capsule())
    }

    private var timerCard: some View {
        HStack(spacing: 38) {
            ZStack {
                Circle().stroke(MoveTheme.forest.opacity(0.08), lineWidth: 13)
                Circle()
                    .trim(from: 0, to: max(0.015, reminder.progress))
                    .stroke(MoveTheme.forest, style: StrokeStyle(lineWidth: 13, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.8), value: reminder.progress)
                Circle()
                    .fill(MoveTheme.mint.opacity(0.55))
                    .padding(23)
                Image(systemName: reminder.phase == .focus ? "leaf.fill" : "figure.walk")
                    .font(.system(size: 38, weight: .medium))
                    .foregroundStyle(MoveTheme.forest)
            }
            .frame(width: 170, height: 170)

            VStack(alignment: .leading, spacing: 11) {
                Text(reminder.phase.eyebrow.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.6)
                    .foregroundStyle(MoveTheme.inkMuted)
                Text(reminder.clockText)
                    .font(.system(size: 53, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .fixedSize(horizontal: true, vertical: false)
                Text(reminder.phase == .focus ? "距离下次活动提醒" : "这一小段时间，只属于身体")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(MoveTheme.inkMuted)

                HStack(spacing: 10) {
                    Button {
                        reminder.togglePause()
                    } label: {
                        Label(reminder.isPaused ? "继续" : "暂停", systemImage: reminder.isPaused ? "play.fill" : "pause.fill")
                            .frame(width: 86, height: 38)
                            .background(MoveTheme.forest)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    Button { reminder.restart() } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .frame(width: 38, height: 38)
                            .background(MoveTheme.mint)
                            .clipShape(Circle())
                    }
                    .help("重新开始")
                }
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .bold))
                .padding(.top, 8)
            }
            Spacer()
        }
        .softCard(padding: 30)
        .frame(maxWidth: .infinity, minHeight: 285)
    }

    private func statCard(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 44, height: 44)
                .background(MoveTheme.mint)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(MoveTheme.inkMuted)
            }

            Spacer()

            Image(systemName: "arrow.up.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(MoveTheme.forest.opacity(0.35))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .softCard(padding: 16)
    }
}

private struct SettingsView: View {
    @EnvironmentObject private var reminder: ReminderManager

    var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            VStack(alignment: .leading, spacing: 6) {
                Text("提醒设置")
                    .font(.system(size: 31, weight: .bold, design: .rounded))
                Text("找到最适合你的工作与休息节奏。")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(MoveTheme.inkMuted)
            }

            VStack(spacing: 0) {
                durationRow(title: "专注时长", subtitle: "每隔多久提醒一次", icon: "timer", value: $reminder.focusMinutes, range: 20...90, step: 5, unit: "分钟")
                Divider().overlay(MoveTheme.line).padding(.leading, 58)
                durationRow(title: "活动时长", subtitle: "留给伸展和走动的时间", icon: "figure.walk", value: $reminder.breakMinutes, range: 2...15, step: 1, unit: "分钟")
            }
            .softCard(padding: 8)

            VStack(spacing: 0) {
                toggleRow(title: "桌面通知", subtitle: "到点后弹出置顶提醒", icon: "rectangle.inset.filled.and.person.filled", value: $reminder.notificationsEnabled)
                Divider().overlay(MoveTheme.line).padding(.leading, 58)
                toggleRow(title: "提醒声音", subtitle: "播放轻量系统提示音", icon: "speaker.wave.2.fill", value: $reminder.soundEnabled)
            }
            .softCard(padding: 8)

            HStack {
                Text("调整时长后，点击应用会开始新一轮专注。")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(MoveTheme.inkMuted)
                Spacer()
                Button("应用设置") { reminder.applyDurations() }
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 22)
                    .frame(height: 42)
                    .background(MoveTheme.forest)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            Spacer()
        }
    }

    private func durationRow(title: String, subtitle: String, icon: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, unit: String) -> some View {
        HStack(spacing: 16) {
            settingIcon(icon)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 14, weight: .bold))
                Text(subtitle).font(.system(size: 11, weight: .medium)).foregroundStyle(MoveTheme.inkMuted)
            }
            Spacer()
            Slider(value: value, in: range, step: step).frame(width: 150).tint(MoveTheme.forest)
            Text("\(Int(value.wrappedValue)) \(unit)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .monospacedDigit()
                .frame(width: 70, alignment: .trailing)
        }
        .padding(16)
    }

    private func toggleRow(title: String, subtitle: String, icon: String, value: Binding<Bool>) -> some View {
        HStack(spacing: 16) {
            settingIcon(icon)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 14, weight: .bold))
                Text(subtitle).font(.system(size: 11, weight: .medium)).foregroundStyle(MoveTheme.inkMuted)
            }
            Spacer()
            Toggle("", isOn: value).labelsHidden().toggleStyle(.switch).tint(MoveTheme.forest)
        }
        .padding(16)
    }

    private func settingIcon(_ icon: String) -> some View {
        Image(systemName: icon)
            .font(.system(size: 15, weight: .semibold))
            .frame(width: 40, height: 40)
            .background(MoveTheme.mint)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}
