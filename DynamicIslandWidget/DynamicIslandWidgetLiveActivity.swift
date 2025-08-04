//
//  DynamicIslandWidgetLiveActivity.swift
//  DynamicIslandWidget
//
//  Created by Eden on 2025/8/4.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DynamicIslandWidgetLiveActivity: Widget
{
    var body: some WidgetConfiguration
    {
        ActivityConfiguration(for: DynamicIslandAttributes.self) { context in
            // 鎖定畫面/橫幅 UI
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                    Text(context.attributes.activityName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(context.state.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(context.state.status))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                ProgressView(value: context.state.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                
                HStack {
                    Text(context.state.currentStep)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("剩餘時間: \(timeRemaining(context.state.timeRemaining))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.1))
            .activitySystemActionForegroundColor(Color.blue)

        } dynamicIsland: { context in
            DynamicIsland {
                // 展開狀態的 UI
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        Text("\(Int(context.state.progress * 100))%")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(alignment: .top, spacing: 0) {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(context.state.status.rawValue)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(self.statusColor(context.state.status))
                            Text(self.timeRemaining(context.state.timeRemaining))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(width: 5, height: 10)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        
                        Text(context.state.currentStep)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        ProgressView(value: context.state.progress)
                            .progressViewStyle(.linear)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                // 緊湊狀態左側
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
            } compactTrailing: {
                // 緊湊狀態右側
                Text("\(Int(context.state.progress * 100))%")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
            } minimal: {
                // 最小狀態
                Image(systemName: context.state.status == .active ? "clock.fill" : "checkmark.circle.fill")
                    .foregroundColor(context.state.status == .active ? .blue : .green)
                    .font(.system(size: 16))
            }
            .widgetURL(URL(string: "dynamicislanddemo://activity"))
            .keylineTint(.blue)
        }
    }
    
    // 輔助函數：根據狀態返回顏色
    private
    func statusColor(_ status: ActivityStatus) -> Color
    {
        switch status {
        case .active:
            return .blue
        case .paused:
            return .orange
        case .completed:
            return .green
        case .cancelled:
            return .red
        }
    }
    
    // 輔助函數：計算剩餘時間
    private
    func timeRemaining(_ endTime: Date) -> String
    {
        let remaining = endTime.timeIntervalSince(Date())
        if remaining <= 0 {
            return "已完成"
        }
        
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension DynamicIslandAttributes
{
    fileprivate
    static
    var preview: DynamicIslandAttributes
    {
        DynamicIslandAttributes(
            activityName: "示範任務",
            startTime: Date()
        )
    }
}

extension DynamicIslandAttributes.ContentState
{
    fileprivate
    static
    var completed: DynamicIslandAttributes.ContentState
    {
        DynamicIslandAttributes.ContentState(
            progress: 1.0,
            currentStep: "任務完成！",
            timeRemaining: Date(),
            status: .completed
        )
    }
    
    fileprivate
    static
    func inProgress(_ progress: Double = 0.5) -> DynamicIslandAttributes.ContentState
    {
        DynamicIslandAttributes.ContentState(
            progress: progress,
            currentStep: "正在進行中...",
            timeRemaining: Date().addingTimeInterval(300 * progress),
            status: .active
        )
    }
}

#Preview("Notification", as: .dynamicIsland(.expanded), using: DynamicIslandAttributes.preview) {
   DynamicIslandWidgetLiveActivity()
} contentStates: {
    DynamicIslandAttributes.ContentState.inProgress(0.3)
    DynamicIslandAttributes.ContentState.inProgress(0.5)
    DynamicIslandAttributes.ContentState.inProgress(0.85)
    DynamicIslandAttributes.ContentState.completed
}
