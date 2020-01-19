//
//  ArchivingManager.swift
//  lab2
//
//  Created by arek on 19/01/2020.
//  Copyright © 2020 aolesek. All rights reserved.
//

import Foundation

class ArchivingManager {
    
    let sensorsDir = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("sensors")
    let readingsDir = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("readings")
    
    // MARK: Generating data
    
    func archivingGenerateData(readingsNumber: Int) -> TimeInterval {
        cleanOldFiles()
        
        let startTime = Date()
        
        // generating
        var sensors: [Sensor] = []
        var readings: [Reading] = []
        generateSensorsAndReadings(&sensors, readingsNumber, &readings)
        
        writeDataToFiles(sensors, readings)
        
        // finish
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        
        print("Finished in \(measuredTime)")
        return measuredTime
    }
    
    fileprivate func cleanOldFiles() {
        //cleaning old files
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: sensorsDir)
        }        catch let x as NSError {
            print("sensors not removed" + x.localizedDescription)
        }
        do {
            try fileManager.removeItem(at: readingsDir)
        }        catch let x as NSError {
            print("readings not removed" + x.localizedDescription)
        }
    }
    
    fileprivate func generateSensorsAndReadings(_ sensors: inout [Sensor], _ readingsNumber: Int, _ readings: inout [Reading]) {
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
    
    fileprivate func writeDataToFiles(_ sensors: [Sensor], _ readings: [Reading]) {
        if let myFileUrl = URL(string: sensorsDir.absoluteString) {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: sensors,
                                                            requiringSecureCoding: false)
                try data.write(to: myFileUrl)
            } catch let x as Error{
                print("Couldn't write sensors file" + x.localizedDescription)
            }
        }
        
        if let myFileUrl = URL(string: readingsDir.absoluteString) {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: readings,
                                                            requiringSecureCoding: false)
                try data.write(to: myFileUrl)
            } catch let x as Error{
                print("Couldn't write readings file" + x.localizedDescription)
            }
        }
    }
    
    //MARK: Query extremal values
    
    fileprivate func readArchivedData(_ sensors: inout [Sensor], _ readings: inout [Reading]) {
        if let sensorsData = NSData(contentsOf: sensorsDir) {
            do {
                if let loadedSensors = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(referencing:sensorsData)) as? [Sensor] {
                    sensors = loadedSensors;
                }
            } catch let x as Error {
                print("Unable to read sensors! " + x.localizedDescription)
            }
        }
        
        
        if let readingsData = NSData(contentsOf: readingsDir) {
            do {
                if let loadedReadings = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(referencing:readingsData)) as? [Reading] {
                    readings = loadedReadings;
                }
            } catch let x as Error {
                print("Unable to read readings! " + x.localizedDescription)
            }
        }
    }
    
    func archivingQueryExt() -> (TimeInterval, Int?, Int?) {
        let startTime = Date()
        
        var sensors: [Sensor] = []
        var readings: [Reading] = []
        
        readArchivedData(&sensors, &readings)
        readings.sort { (r1, r2) -> Bool in
            return r1.timestamp < r2.timestamp
        }
        
        let largestTimestamp = readings.first?.timestamp
        let smallestTimestamp = readings.last?.timestamp
        
        
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        
        print("Querying minmax finished in \(measuredTime)")
        return (measuredTime, largestTimestamp, smallestTimestamp)
    }
    
    func archivingQueryAvg() -> (TimeInterval, Double) {
        let startTime = Date()
        
        var sensors: [Sensor] = []
        var readings: [Reading] = []
        
        readArchivedData(&sensors, &readings)
        
        var sum: Double = 0.0;
        readings.forEach { (reading) in
            sum += Double(reading.value)
        }
        
        let avg = sum / Double(readings.count)

        
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        
        print("Querying avg finished in \(measuredTime)")
        return (measuredTime, avg)
    }
    
    func archivingQuerySensorStats() -> (TimeInterval, [(Sensor, Double)]) {
        let startTime = Date()
        
        var sensors: [Sensor] = []
        var readings: [Reading] = []
        readArchivedData(&sensors, &readings)
        
        var averages: [(Sensor, Double)] = []
        sensors.forEach { (sensor) in
            let readingsForSensor = readings.filter { (reading) -> Bool in
                return reading.sensorName == sensor.name
            }
            
            var sum: Double = 0.0;
            readingsForSensor.forEach { (readingForSensor) in
                sum += Double(readingForSensor.value)
            }
            let avg = sum / Double(readingsForSensor.count)
            
            averages.append((sensor, avg))
        }
        
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        
        print("Querying avg per sensor finished in \(measuredTime)")
        
        return (measuredTime, averages)
    }
    
    func getRandomSensor(sensors: [Sensor]) -> Sensor {
        let sensorNumber = Int.random(in: 0 ..< sensors.count)
        return sensors[sensorNumber]
    }
}
