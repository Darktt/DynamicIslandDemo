//
//  ViewController.swift
//  DynamicIslandDemo
//
//  Created by Eden on 2025/8/4.
//

import UIKit
import ActivityKit

class ViewController: UIViewController
{
    
    private var currentActivity: Activity<DynamicIslandAttributes>?

    override
    func viewDidLoad()
    {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private
    func setupUI()
    {
        self.view.backgroundColor = .systemBackground
        
        // 創建開始動態島按鈕
        let startButton = UIButton(type: .system)
        startButton.setTitle("開始動態島活動", for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 10
        
        let startAction = UIAction {
            
            [weak self] _ in
            
            self?.startLiveActivity()
        }
        startButton.addAction(startAction, for: .touchUpInside)
        
        // 創建停止動態島按鈕
        let stopButton = UIButton(type: .system)
        stopButton.setTitle("停止動態島活動", for: .normal)
        stopButton.backgroundColor = .systemRed
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.layer.cornerRadius = 10
        
        let stopAction = UIAction {
            
            [weak self] _ in
            
            self?.stopLiveActivity()
        }
        stopButton.addAction(stopAction, for: .touchUpInside)
        
        // 設置按鈕佈局
        startButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(startButton)
        self.view.addSubview(stopButton)
        
        NSLayoutConstraint.activate([
            startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            startButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            
            stopButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            stopButton.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 20),
            stopButton.widthAnchor.constraint(equalToConstant: 200),
            stopButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc
    private
    func startLiveActivity()
    {
        // 檢查設備是否支援動態島
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            
            self.showAlert(title: "不支援", message: "此設備不支援 Live Activities")
            return
        }
        
        // 創建靜態內容
        let attributes = DynamicIslandAttributes(
            activityName: "示範活動",
            startTime: Date()
        )
        
        // 創建動態內容
        let contentState = DynamicIslandAttributes.ContentState(
            progress: 0.0,
            currentStep: "開始執行",
            timeRemaining: Date().addingTimeInterval(300), // 5分鐘後
            status: .active
        )
        
        do {
            // 啟動 Live Activity
            let activityContent = ActivityContent(state: contentState, staleDate: Date().addingTimeInterval(60))
            
            let activity = try Activity<DynamicIslandAttributes>.request(
                attributes: attributes,
                content: activityContent
            )
            
            self.currentActivity = activity
            print("✅ 動態島活動已啟動，ID: \(activity.id)")
            self.showAlert(title: "成功", message: "動態島活動已啟動！")
            
            // 模擬進度更新
            self.simulateProgressUpdate()
            
        } catch {
            
            print("❌ 啟動動態島失敗: \(error)")
            self.showAlert(title: "錯誤", message: "啟動失敗: \(error.localizedDescription)")
        }
    }
    
    @objc
    private
    func stopLiveActivity()
    {
        guard let activity = self.currentActivity else {
            
            self.showAlert(title: "提示", message: "沒有進行中的活動")
            return
        }
        
        let finalState = DynamicIslandAttributes.ContentState(
            progress: 1.0,
            currentStep: "已完成",
            timeRemaining: Date(),
            status: .completed
        )
        
        Task {
            
            let activityContent = ActivityContent(state: finalState, staleDate: Date().addingTimeInterval(60))
            await activity.end(activityContent, dismissalPolicy: .immediate)
            
            DispatchQueue.main.async {
                
                [weak self] in
                
                self?.currentActivity = nil
                self?.showAlert(title: "完成", message: "動態島活動已結束")
            }
        }
    }
    
    private
    func simulateProgressUpdate()
    {
        var progress: Double = 0.1
        
        let updateHandler: (Timer) -> Void = {
            
            [weak self] timer in
            
            guard let activity = self?.currentActivity else {
                
                timer.invalidate()
                return
            }
            
            progress += 0.1
            
            let updatedState = DynamicIslandAttributes.ContentState(
                progress: min(progress, 1.0),
                currentStep: "步驟 \(Int(progress * 5))",
                timeRemaining: Date().addingTimeInterval(300 - (progress * 300)),
                status: progress >= 1.0 ? .completed : .active
            )
            
            Task {
                
                await activity.update(
                    .init(
                        state: updatedState,
                        staleDate: Date().addingTimeInterval(60)
                    )
                )
            }
            
            if progress >= 1.0 {
                
                timer.invalidate()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: updateHandler)
    }
    
    private
    func showAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        
        self.present(alert, animated: true)
    }
}
