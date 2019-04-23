//
//  XZCoreMotionController.swift
//  XZHealthDemo
//
//  Created by admin on 2019/4/22.
//  Copyright © 2019 admin. All rights reserved.
//  CoreMotion 方式实现

import UIKit


class XZCoreMotionController: UIViewController {
    
    @IBOutlet weak var labelStepCount: UILabel!
    
    let manager = XZCoreMotionManager()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    /// 查询步数
    @IBAction func queryStepCountAction(_ sender: UIButton) {
        manager.startPedometer { (isSuccess, stepCount) in
            if isSuccess {
                
                DispatchQueue.main.async {
                    self.labelStepCount.text = "\(stepCount)步"
                }
                print("----查询成功")
            }else {
                print("----查询失败")
            }
        }
    }
    
}
