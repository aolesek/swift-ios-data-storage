//
//  Utils.swift
//  lab2
//
//  Created by arek on 19/01/2020.
//  Copyright © 2020 aolesek. All rights reserved.
//
import UIKit
import Foundation

struct Utils {
    
    static let DEFAULT_READINGS_NUMBER = 100

    static func getReadingsNumber(numberOfReadings: UITextField!) -> Int {
        if let text = numberOfReadings?.text {
            if let number = Int(text) {
                return number
            }
        }
        return DEFAULT_READINGS_NUMBER
    }
    
    static func generateRandomTimestamp() -> Int {
        let currentTime = Int(Date().timeIntervalSince1970)
        let randomIntervalLessThanAYear = Int.random(in: 0 ..< 31556926)
        let randomTime = currentTime - randomIntervalLessThanAYear;
        return randomTime
    }
    
    static func generateRandomValue() -> Float {
        return Float.random(min: 0.0, max: 100.0)
    }
}
