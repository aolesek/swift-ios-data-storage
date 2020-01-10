//
//  ViewController.swift
//  lab2
//
//  Created by arek on 10/01/2020.
//  Copyright © 2020 aolesek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let DEFAULT_READINGS_NUMBER = 100
    
    @IBOutlet weak var numberOfReadings: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK: Utils
    
    func getReadingsNumber() -> Int {
        if let text = numberOfReadings?.text {
            if let number = Int(text) {
                return number
            }
        }
        return DEFAULT_READINGS_NUMBER
    }
    
    func generateRandomTimestamp() -> Int {
        let currentTime = Int(Date().timeIntervalSince1970)
        let randomIntervalLessThanAYear = Int.random(in: 0 ..< 31556926)
        let randomTime = currentTime - randomIntervalLessThanAYear;
        return randomTime
    }
    
    func generateRandomValue() -> Float {
        return Float.random(min: 0.0, max: 100.0)
    }
    
    //MARK: Archiving
    
    @IBOutlet weak var archivingGenerationTime: UITextField!
    @IBOutlet weak var archivingExtQueryTime: UITextField!
    @IBOutlet weak var archivingAvgQueryTime: UITextField!
    @IBOutlet weak var archivingSensorStatsQueryTime: UITextField!
    
    @IBAction func archivingGenerateData(_ sender: Any) {
        //cleaning old files
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(atPath: "sensors.bin")
        }        catch _ as NSError {
            print("sensors not removed")
        }
        do {
            try fileManager.removeItem(atPath: "readings.bin")
        }        catch _ as NSError {
            print("readings not removed")
        }
        
        let startTime = Date()
        // generating
        var sensors: [Sensor] = []
        for n in 1...20 {
            let name = (n < 10 ?"S0\(n)" : "S\(n)")
            sensors.append(Sensor(name: name , description: "Sensor number \(n)"))
        }
        print("Sensors generated.")
        
        var readings: [Reading] = []
        for _ in 1...getReadingsNumber() {
            readings.append(Reading(timestamp: generateRandomTimestamp(), sensor: getRandomSensor(sensors: sensors), value: generateRandomValue()))
        }
        print("Readings generated.")
        
        if let myFileUrl = URL(string: "sensors.bin") {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: sensors,
                                                            requiringSecureCoding: false)
                try data.write(to: myFileUrl)
            } catch {
                print("Couldn't write sensors file")
            }
        }
        
        if let myFileUrl = URL(string: "readings.bin") {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: readings,
                                                            requiringSecureCoding: false)
                try data.write(to: myFileUrl)
            } catch {
                print("Couldn't write readings file")
            }
        }
        
        // finish
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        
        print("Finished in \(measuredTime)")
        archivingGenerationTime?.text = String(measuredTime)
    }
    
    @IBAction func archivingQueryExt(_ sender: Any) {
        archivingExtQueryTime?.text = "?"
    }
    
    @IBAction func archivingQueryAvg(_ sender: Any) {
        archivingAvgQueryTime?.text = "?"
    }
    
    @IBAction func archivingQuerySensorStats(_ sender: Any) {
        archivingSensorStatsQueryTime?.text = "?"
    }
    
    func getRandomSensor(sensors: [Sensor]) -> Sensor {
        let sensorNumber = Int.random(in: 0 ..< sensors.count)
        return sensors[sensorNumber]
    }
    
    //MARK: SQLite
    
    @IBOutlet weak var sqlGenerationTime: UITextField!
    @IBOutlet weak var sqlExtQueryTime: UITextField!
    @IBOutlet weak var sqlAvgQueryTime: UITextField!
    @IBOutlet weak var sqlSensorStatsQueryTime: UITextField!
    
    @IBAction func sqlGenerateData(_ sender: Any) {
        sqlGenerationTime?.text = "?"
    }
    
    @IBAction func sqlQueryExt(_ sender: Any) {
        sqlExtQueryTime?.text = "?"
    }
    
    @IBAction func sqlQueryAvg(_ sender: Any) {
        sqlAvgQueryTime?.text = "?"
    }
    
    @IBAction func sqlQuerySensorStats(_ sender: Any) {
        sqlSensorStatsQueryTime?.text = "?"
    }
    
    //MARK: Core Data
    
    @IBOutlet weak var coreGenerationTime: UITextField!
    @IBOutlet weak var coreExtQueryTime: UITextField!
    @IBOutlet weak var coreAvgQueryTime: UITextField!
    @IBOutlet weak var coreSensorStatsQueryTime: UITextField!
    
    @IBAction func coreGenerateData(_ sender: Any) {
        coreGenerationTime?.text = "?"
    }
    
    @IBAction func coreQueryExt(_ sender: Any) {
        coreExtQueryTime?.text = "?"
    }
    
    @IBAction func coreQueryAvg(_ sender: Any) {
        coreAvgQueryTime?.text = "?"
    }
    
    @IBAction func coreQuerySensorStats(_ sender: Any) {
        coreSensorStatsQueryTime?.text = "?"
    }
}

public extension Float {

    static var random: Float {
        return Float(arc4random()) / 0xFFFFFFFF
    }

    static func random(min: Float, max: Float) -> Float {
        return Float.random * (max - min) + min
    }
}
