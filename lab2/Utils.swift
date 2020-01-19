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
    
    static func generateSensorsAndReadings(_ sensors: inout [Sensor], _ readingsNumber: Int, _ readings: inout [Reading]) {
        for n in 1...20 {
            let name = (n < 10 ?"S0\(n)" : "S\(n)")
            sensors.append(Sensor(name: name , description: "Sensor number \(n)"))
        }
        print("Sensors generated.")
        
        for _ in 1...readingsNumber {
            readings.append(Reading(timestamp: Utils.generateRandomTimestamp(), sensorName: getRandomSensor(sensors: sensors).name, value: Utils.generateRandomValue()))
        }
        print("Readings generated.")
    }
    
    static func getRandomSensor(sensors: [Sensor]) -> Sensor {
        let sensorNumber = Int.random(in: 0 ..< sensors.count)
        return sensors[sensorNumber]
    }
    
    static func generateSqlSensorsAndReadings(_ sensors: inout [SqlSensor], _ readingsNumber: Int, _ readings: inout [SqlReading]) {
        for n in 1...20 {
            let name = (n < 10 ?"S0\(n)" : "S\(n)")
            sensors.append(SqlSensor(id: n, name: name , description: "Sensor number \(n)"))
        }
        print("Sensors generated.")
        
        for m in 1...readingsNumber {
            let sensorId = Int.random(in: 1 ..< 21)
            
            readings.append(SqlReading(id: m, timestamp: Utils.generateRandomTimestamp(), value: Utils.generateRandomValue(), sensor: sensorId))
        }
        print("Readings generated.")
    }
}
