//
//  XZCoreMotionManager.swift
//  XZHealthDemo
//
//  Created by admin on 2019/4/22.
//  Copyright © 2019 admin. All rights reserved.
//  

import Foundation
import CoreMotion

class XZCoreMotionManager: NSObject {
    
    private let pedometer = CMPedometer()
    
    /// 开始查询
    func startPedometer(completed: @escaping ((_ isSuccess: Bool, _ stepCount: Int)->Void)) {
        
        if CMPedometer.isStepCountingAvailable() {
            
            pedometer.startUpdates(from: Date(timeIntervalSinceNow: -24*60*60*2)) { (data, error) in
                
                if error != nil {
                    completed(false, 0)
                    print("error:", error as Any)
                }else {
                    print("data:", data?.numberOfSteps.intValue as Any)
                    completed(true, (data?.numberOfSteps.intValue)!)
                }
            }
        }else {
            
            print("----需要授权，iOS 8 以上系统才可用。")
            completed(false, 0)
        }
    }
    
    /// 停止查询
    
    /// 实时更新数据
    
    /// 查询步数
    func queryStepCount() {
        
        // 步数读写功能可用
        if CMPedometer.isStepCountingAvailable() {
            if #available(iOS 11.0, *) {
                if CMPedometer.authorizationStatus() == .authorized {
                    
                }
            } else {
                print("系统版本低于 11.0")
                // Fallback on earlier versions
            }
        }
        
    }
    
//    case notDetermined // 不确定
//
//    case restricted  // 限制
//
//    case denied      // 拒绝
//
//    case authorized  // 已授权
    
}
