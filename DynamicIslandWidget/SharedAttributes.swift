import Foundation
import ActivityKit

// 動態島數據模型 - 共享給 Widget Extension
struct DynamicIslandAttributes: ActivityAttributes 
{
    public struct ContentState: Codable, Hashable 
    {
        // 動態內容（會變化的數據）
        var progress: Double
        var currentStep: String
        var timeRemaining: Date
        var status: ActivityStatus
    }
    
    // 靜態內容（不會變化的數據）
    var activityName: String
    var startTime: Date
}

// 活動狀態枚舉
enum ActivityStatus: String, Codable, CaseIterable 
{
    case active = "進行中"
    case paused = "暫停"
    case completed = "完成"
    case cancelled = "取消"
}