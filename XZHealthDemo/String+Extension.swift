//
//  String+Extension.swift
//  XZHealthDemo
//
//  Created by admin on 2019/4/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

extension String {
    
    /// floatValue
    func floatValue() -> CGFloat {
        let doubleValue = Double(self)
        return CGFloat(doubleValue ?? 0)
    }
    
}
