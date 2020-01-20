//
//  CoreDataManager.swift
//  lab2
//
//  Created by arek on 19/01/2020.
//  Copyright © 2020 aolesek. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    private let moc: NSManagedObjectContext
    
    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }
    
    //MARK: Generating and utils
    func coreGenerate(readingsNumber: Int) -> TimeInterval {
        let startTime = Date()
        
        reset()
        var sensors: [CoreSensor] = []
        var readings: [CoreReading] = []
        coreGenerateData(&sensors, readingsNumber, &readings)
        persist();
        
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        print("CoreData generate finished in \(measuredTime)")
        return measuredTime
    }
    
    private func coreGenerateData(_ sensors: inout [CoreSensor], _ readingsCount: Int, _ readings: inout [CoreReading]) {
        
        for n in 1...20 {
            let newSensor = CoreSensor(context: moc)
            newSensor.name = "S" + String(n)
            newSensor.desc = "Sensor number \(n)"
            
            sensors.append(newSensor)
        }
        
        for _ in 1...readingsCount {
            let newReading = CoreReading(context: moc)
            newReading.timestamp = Int32(Utils.generateRandomTimestamp())
            newReading.sensor = sensors[Int.random(in: 0 ..< 20)]
            newReading.value = Double(Utils.generateRandomValue())
            readings.append(newReading)
        }
    }
    
    func persist() {
        do {
            try moc.save()
        } catch let e as NSError {
            print ("Unable to persist data!" + e.localizedDescription)
        }
    }
    
    func reset() {
        if let data = readPersistedData() {
            data.0.forEach( {moc.delete($0)})
            data.1.forEach( {moc.delete($0)})
            persist();
        } else {
            print("Unable to reset! Persisted data not present!")
        }
    }
    
    func readPersistedData() -> ([CoreSensor], [CoreReading])? {
        let fetchSensorRequest: NSFetchRequest<CoreSensor> = CoreSensor.fetchRequest()
        let fetchReadingRequest: NSFetchRequest<CoreReading> = CoreReading.fetchRequest()
        
        do {
            let sensors = try moc.fetch(fetchSensorRequest)
            let readings = try moc.fetch(fetchReadingRequest)
            return (sensors, readings)
        } catch let e as NSError {
            print("Unable to fetch data from CoreData! " + e.localizedDescription);
            return nil
        }
    }
    
    //MARK: Min and max timestamp
    
    func coreMinMax() -> (TimeInterval, Int?, Int?) {
        let startTime = Date()
        
        let minExpDesc = NSExpressionDescription()
        minExpDesc.expressionResultType = .integer32AttributeType
        minExpDesc.name = "min timestamp"
        minExpDesc.expression = NSExpression(format: "@min.timestamp")
        
        let maxExpDesc = NSExpressionDescription()
        maxExpDesc.expressionResultType = .integer32AttributeType
        maxExpDesc.name = "max timestamp"
        maxExpDesc.expression = NSExpression(format: "@max.timestamp")
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreReading")
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [minExpDesc, maxExpDesc]
        
        var min: Int? = nil
        var max: Int? = nil
        do {
            let result = try moc.fetch(fetchRequest)
            if let resultAsDictionary = result[0] as? [String: Int] {
                min = resultAsDictionary["min timestamp"]
                max = resultAsDictionary["max timestamp"]
            }
        } catch let e as NSError {
            print("Unable to fetch data! " + e.localizedDescription)
        }
        
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        
        print("CoreData minmax query finished in \(measuredTime)")
        return (measuredTime, min, max)
    }
    
    //MARK: Core avg
    func coreAvg() -> (TimeInterval, Double?) {
        let startTime = Date()
        
        let key = NSExpression(forKeyPath: "value")
        let avgExpDesc = NSExpressionDescription()
        avgExpDesc.expressionResultType = .doubleAttributeType
        avgExpDesc.name = "avg value"
        avgExpDesc.expression = NSExpression(forFunction: "average:", arguments: [key])
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreReading")
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = [avgExpDesc]
        
        var avg: Double? = nil
        do {
            let result = try moc.fetch(fetchRequest)
            if let dict = result[0] as? [String: Double] {
                avg = dict["avg value"]
            }
        } catch let e as NSError {
            print("Unable to fetch data! " + e.localizedDescription)
        }
        
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        
        print("CoreData avg query finished in \(measuredTime)")
        return (measuredTime, avg)
    }
    
    //MARK: Core avg per sensor
    
    func coreAvgPerSensor() -> (TimeInterval, [(String, Double)]) {
        let startTime = Date()
        
        var res: [(String, Double)] = []
        
        let key = NSExpression(forKeyPath: "value")
        let avgExpDesc = NSExpressionDescription()
        avgExpDesc.expressionResultType = .doubleAttributeType
        avgExpDesc.name = "avg value"
        avgExpDesc.expression = NSExpression(forFunction: "average:", arguments: [key])
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreReading")
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["sensor.name"]
        fetchRequest.propertiesToFetch = ["sensor.name", avgExpDesc]
        
        do {
            if let results = try moc.fetch(fetchRequest) as? [NSDictionary] {
                for d in results {
                    if let sensor = d["sensor.name"] as? String,
                        let avg = d["avg value"] as? Double {
                        res.append((sensor, avg))
                    }
                }
            }
        } catch let e as NSError {
            print("Unable to fetch data! " + e.localizedDescription)
        }
        
        
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        
        print("CoreData avg per sensor query finished in \(measuredTime)")
        return (measuredTime, res)
    }
}
