import SwiftUI

struct BlockingReminderScreen: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.62)
                .ignoresSafeArea()
                .contentShape(Rectangle())

            RadialGradient(
                colors: [MoveTheme.mint.opacity(0.16), .clear],
                center: .center,
                startRadius: 40,
                endRadius: 520
            )
            .ignoresSafeArea()

            ReminderOverlayView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SecondaryScreenMask: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.68).ignoresSafeArea()
            VStack(spacing: 14) {
                LeafMark(size: 54)
                Text("休息时间")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("请在主屏幕完成本次活动提醒")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.68))
            }
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ReminderOverlayView: View {
    @EnvironmentObject private var reminder: ReminderManager
    @State private var appeared = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(MoveTheme.cream)
                .shadow(color: .black.opacity(0.22), radius: 38, y: 18)

            Circle()
                .fill(MoveTheme.mint)
                .frame(width: 290, height: 290)
                .offset(x: 225, y: -175)
            Circle()
                .fill(MoveTheme.lime.opacity(0.28))
                .frame(width: 180, height: 180)
                .offset(x: -260, y: 190)

            VStack(spacing: 0) {
                HStack {
                    HStack(spacing: 10) {
                        LeafMark(size: 34)
                        Text("MOVE EASE")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.7)
                    }
                    Spacer()
                    Text(reminder.isActivityRunning ? "活动进行中" : "活动 \(Int(reminder.breakMinutes)) 分钟")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 13)
                        .frame(height: 30)
                        .background(MoveTheme.mint)
                        .clipShape(Capsule())
                }

                if reminder.isActivityRunning {
                    activityTimerContent
                        .transition(.opacity.combined(with: .scale(scale: 0.94)))
                } else {
                    reminderPromptContent
                        .transition(.opacity.combined(with: .scale(scale: 0.94)))
                }
            }
            .padding(28)
        }
        .frame(width: 560, height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .stroke(MoveTheme.forest.opacity(0.12), lineWidth: 1)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.68).delay(0.08)) {
                appeared = true
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: reminder.isActivityRunning)
    }

    private var reminderPromptContent: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(MoveTheme.forest)
                    .frame(width: 98, height: 98)
                Image(systemName: "figure.cooldown")
                    .font(.system(size: 43, weight: .medium))
                    .foregroundStyle(MoveTheme.lime)
            }
            .scaleEffect(appeared ? 1 : 0.55)
            .opacity(appeared ? 1 : 0)

            Text("该起身松一松啦")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .padding(.top, 18)
            Text("看看远处，转转肩膀，再去接一杯水。\n屏幕会等你，身体也值得被照顾。")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(MoveTheme.inkMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.top, 9)

            Spacer()

            HStack(spacing: 12) {
                Button("5 分钟后提醒") { reminder.snooze() }
                    .frame(width: 160, height: 44)
                    .background(MoveTheme.mint)
                    .clipShape(Capsule())
                Button {
                    reminder.startActivity()
                } label: {
                    Label("我去活动", systemImage: "arrow.right")
                        .frame(width: 160, height: 44)
                        .background(MoveTheme.forest)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .buttonStyle(.plain)
            .font(.system(size: 13, weight: .bold))
        }
    }

    private var activityTimerContent: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(MoveTheme.forest.opacity(0.1), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: max(0.015, reminder.progress))
                    .stroke(MoveTheme.forest, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.8), value: reminder.progress)
                VStack(spacing: 1) {
                    Text(reminder.clockText)
                        .font(.system(size: 31, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    Text("活动中")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(MoveTheme.inkMuted)
                }
            }
            .frame(width: 124, height: 124)

            Text("好好活动，不着急回来")
                .font(.system(size: 27, weight: .bold, design: .rounded))
                .padding(.top, 15)
            Text("离开屏幕，走一走，让眼睛和肩颈真正休息。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(MoveTheme.inkMuted)
                .padding(.top, 7)

            Spacer()

            Button {
                reminder.finishBreak()
            } label: {
                Label("提前完成活动", systemImage: "checkmark")
                    .frame(width: 210, height: 42)
                    .background(MoveTheme.mint)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .font(.system(size: 12, weight: .bold))
        }
    }
}
