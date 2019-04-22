//
//  XZHealthManager.swift
//  XZHealthDemo
//
//  Created by admin on 2019/4/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import HealthKit

class XZHealthyManager: NSObject {
    
    let healthStore = HKHealthStore()
    
    // 授权 步数 读写
    func authorizeStepCount(completed: @escaping ((_ isSuccess: Bool)->Void)) {
        
        if HKHealthStore.isHealthDataAvailable() {
            let writeTypes = stepCountToWrite()
            let readTypes = stepCountToRead()
            
            healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { (success, error) in
                
                completed(success)
                print("----步数读写：", success)
            }
        }
    }
    
    /// 授权状态
    func authorizeStatus(){
        
//        healthStore.authorizationStatus(for: <#T##HKObjectType#>)
        
        let writeTypes = stepCountToWrite()
        let readTypes = stepCountToRead()
        
        if #available(iOS 12.0, *) {
            healthStore.getRequestStatusForAuthorization(toShare: writeTypes!, read: readTypes!) { (status, error) in
                
                print("-----授权状态：", status.rawValue, "----错误：", error)
            }
        } else {
            print("系统小于 iOS 12.0")
            // Fallback on earlier versions
        }
        
    }
    
    // 授权 读写 健康数据
    func authorizeHealthKit(completed: @escaping ((_ isSuccess: Bool)->Void)) {
        
        let version = UIDevice.current.systemVersion.floatValue()
        
        if version >= 8.0 {
            if !HKHealthStore.isHealthDataAvailable() {
                
//                let error = NSError(domain: "com.xz.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in th is Device"])
                
                completed(false)
            }else { // 可用
                // 需要读写的数据类型
                let writeDataTypes = dateTypeToWrite()
                let readDataTypes = dateTypeToRead()
                
                // 注册需要读写的数据类型，也可以在'健康'中重新修改
                healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes, completion: { (isSuccess, error) in
                    
                    print("错误：", error)
                    print("权限结果：", isSuccess)
                    
                    completed(isSuccess)
                })
            }
        }else {
            print("iOS 系统低于8.0")
            completed(false)
        }
    }
    
    /// 修改数据
    func recordStepData(step: Int, completed: @escaping ((_ success: Bool)->Void)) {
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        
        if HKHealthStore.isHealthDataAvailable() {
            let stepQuantity = HKQuantity(unit: HKUnit.count(), doubleValue: Double(step))
            let stepSample = HKQuantitySample(type: stepType!, quantity: stepQuantity, start: Date(), end: Date())
            
            healthStore.save(stepSample) { (isSuccess, error) in
                
                print("修改结果：", isSuccess)
                completed(isSuccess)
            }
        }else {
            print("写入不允许")
        }
    }
    
    /// 步数 读 权限
    func stepCountToRead() -> Set<HKQuantityType>? {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        
        return Set(arrayLiteral: stepType!)
    }
    
    /// 步数 写 权限
    func stepCountToWrite() -> Set<HKQuantityType>? {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        
        return Set(arrayLiteral: stepType!)
    }
    
    // 读取 Health 数据
    func dateTypeToRead() -> Set<HKQuantityType>? {
        // 身高
        let heightType = HKObjectType.quantityType(forIdentifier: .height)
        // 体重
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)
        // 体温
        let temperatureType = HKObjectType.quantityType(forIdentifier: .bodyTemperature)
        // 生日
        let birthdayType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)
        // 性别
        let sexType = HKObjectType.characteristicType(forIdentifier: .biologicalSex)
        // 步数
        let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)
        // 距离
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
        // 活动能量
        let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
        
        return Set(arrayLiteral: heightType, temperatureType, birthdayType, sexType, weightType, stepCountType, distanceType, activeEnergyType) as? Set<HKQuantityType>
    }
    
    // 写 Health 数据
    func dateTypeToWrite() -> Set<HKQuantityType>? {
        // 身高
        let heightType = HKObjectType.quantityType(forIdentifier: .height)
        // 体重
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)
        // 体温
        let temperatureType = HKObjectType.quantityType(forIdentifier: .bodyTemperature)
        // 活动能量
        let activeEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
        
        return Set(arrayLiteral: heightType, temperatureType, weightType, activeEnergyType) as? Set<HKQuantityType>
    }
    
    /// 获取步数
    func getStepCount(completion: @escaping ((_ value: Int)->Void)) {
        // 步数
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)
        
        let timeSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: stepType!, predicate: predicateForSampelsToday(), limit: HKObjectQueryNoLimit, sortDescriptors: [timeSortDescriptor]) { (query, results, error) in
            
            if error != nil {
                
                completion(0)
            }else {
                var totalStep = 0
                
                if let results = results {
                    for quantitySample in results {
                        
                        let quantitySam = quantitySample as! HKQuantitySample
                        
                        let quantity = quantitySam.quantity
                        let heightUnit = HKUnit.count()
                        let usersHeight = quantity.doubleValue(for: heightUnit)
                        totalStep += Int(usersHeight)
                    }
                    
                    print("当天行走步数 =", totalStep)
                    completion(totalStep)
                }
            }
        }
        
        // 执行查询
        healthStore.execute(query)
    }
    
    /// 获取公里数
    func getDistance(completion: @escaping ((_ value: Double, _ error: NSError)->Void)) {
        // 距离
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
        
        let timeSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: distanceType!, predicate: predicateForSampelsToday(), limit: HKObjectQueryNoLimit, sortDescriptors: [timeSortDescriptor]) { (query, results, error) in
            
            if error != nil {
                
                completion(0, error! as NSError)
            }else {
                var totalSteps: Double = 0
                
                if let results = results {
                    for quantitySample in results {
                        let quantitySam = quantitySample as! HKQuantitySample
                        
                        let quantity = quantitySam.quantity
                        let distanceUnit = HKUnit.meterUnit(with: .kilo)
                        
                        let usersHeight = quantity.doubleValue(for: distanceUnit)
                        
                        totalSteps += usersHeight
                    }
                    
                    print("当天行走距离=", totalSteps)
                    
                    completion(totalSteps, error! as NSError)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    /// 当天时间段
    func predicateForSampelsToday() -> NSPredicate {
        let calendar = Calendar.current
        let now = Date()
        
        let dateComponets: Set<Calendar.Component> = Set(arrayLiteral: Calendar.Component.year, Calendar.Component.month, Calendar.Component.day)
        
        var componets = calendar.dateComponents(dateComponets, from: now)
        componets.hour = 0
        componets.minute = 0
        componets.second = 0
        
        let startDate = calendar.date(from: componets)
        let endDate = calendar.date(byAdding: Calendar.Component.day, value: 1, to: startDate!)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.init(rawValue: 0))
        
        return predicate
    }
    
    
}
