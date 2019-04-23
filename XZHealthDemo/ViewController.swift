//
//  ViewController.swift
//  XZHealthDemo
//
//  Created by admin on 2019/4/19.
//  Copyright © 2019 admin. All rights reserved.
//  HealthKit 方式实现

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textChangeStep: UITextField!
    
    @IBOutlet weak var labelSteps: UILabel!
    
    private let manager = XZHealthyManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "HealthKit"
        
        //
        manager.authorizeStepCount { (success) in }
        
    }
    
    /// 向系统中添加步数
    @IBAction func addStepToSystem(_ sender: UIButton) {
        textChangeStep.resignFirstResponder()
        
        manager.authorizeStatus()
        
        manager.authorizeHealthKit { (isSuccess) in
            
            if isSuccess {
                DispatchQueue.main.async {
                    self.manager.recordStepData(step: Int(self.textChangeStep.text!) ?? 0) { (isSuccess) in
                        
                        if isSuccess {
                            print("----步数添加成功")
                        }else {
                            print("----步数添加失败")
                        }
                    }
                }
            }else {
                print("授权失败")
            }
        }
        
    }
    
    /// 从系统中获取步数
    @IBAction func getStepFromSystem(_ sender: UIButton) {
        
        manager.authorizeHealthKit { (isSuccess) in
            if isSuccess {
                self.manager.getStepCount(completion: { (value) in
                    
                    print("获取的步数是:", value)
                    DispatchQueue.main.async {
                        self.labelSteps.text = String(format: "%d步", value)
                    }
                })
            }else {
                print("获取数据失败")
            }
        }
        
    }
    
    
}

