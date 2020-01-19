//
//  ViewController.swift
//  lab2
//
//  Created by arek on 10/01/2020.
//  Copyright © 2020 aolesek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var numberOfReadings: UITextField!
    @IBOutlet weak var console: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func time(_ measuredTime: TimeInterval) -> String {
        return String(format: "[%.4f s] ", measuredTime)
    }
    
    func log(_ str: String) {
        console.text = console.text + "\n" + str;
    }
    
    //MARK: Archiving
    
    let archiving = ArchivingManager()
    
    @IBAction func archivingGenerateData(_ sender: Any) {
        let measuredTime = archiving.archivingGenerateData(readingsNumber: Utils.getReadingsNumber(numberOfReadings: numberOfReadings))
        log(time(measuredTime) + "Data generated.")
    }
    
    @IBAction func archivingQueryExt(_ sender: Any) {
        let result = archiving.archivingQueryExt()
        log(time(result.0) + String(format: "Min: %d, max: %d.", result.1! , result.2!))
    }
    
    @IBAction func archivingQueryAvg(_ sender: Any) {
        let result = archiving.archivingQueryAvg()
        log(time(result.0) + String(format: "Average value: %f.", result.1))
    }
    
    @IBAction func archivingQuerySensorStats(_ sender: Any) {
        let result = archiving.archivingQuerySensorStats()
        log(time(result.0) + String(format: "Calculated average for %d sensors.", result.1.count))
        result.1.forEach { (s, d) in
                log("Average for \(s.name) is \(d).");
            }
    }
    
    //MARK: SQLite
    @IBAction func sqlGenerate(_ sender: Any) {
        log("sql not implemented")
    }
    @IBAction func sqlMinMax(_ sender: Any) {
        log("sql not implemented")
    }
    @IBAction func sqlAvg(_ sender: Any) {
        log("sql not implemented")
    }
    @IBAction func sqlAvgPerSensor(_ sender: Any) {
        log("sql not implemented")
    }
    
    //MARK: Core Data
    @IBAction func coreGenerate(_ sender: Any) {
        log("core data not implemented")
    }
    @IBAction func coreMinMax(_ sender: Any) {
        log("core data not implemented")
    }
    @IBAction func coreAvg(_ sender: Any) {
        log("core data not implemented")
    }
    @IBAction func coreAvgPerSensor(_ sender: Any) {
        log("core data not implemented")
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
