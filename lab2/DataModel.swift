//
//  DataModel.swift
//  lab2
//
//  Created by arek on 10/01/2020.
//  Copyright © 2020 aolesek. All rights reserved.
//

import Foundation

class Sensor: NSObject, NSCoding {
    
    let name: String
    let desc: String
    
    init(name: String, description: String) {
        self.name = name
        self.desc = description
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(desc, forKey: PropertyKey.desc)
    }
    
    required convenience init?(coder: NSCoder) {
        guard let name = coder.decodeObject(forKey: PropertyKey.name) as? String else {
            NSLog("Unable to decode name for Sensor")
            return nil
        }
        guard let desc = coder.decodeObject(forKey: PropertyKey.desc) as? String else {
            NSLog("Unable to decode description for Sensor")
            return nil
        }
        
        self.init(name: name, description: desc)
    }
    
    struct PropertyKey {
        static let name = "name"
        static let desc = "desc"
    }
}

class Reading: NSObject, NSCoding {
    
    let timestamp: Int
    var sensor: Sensor
    let value: Float
    
    init(timestamp: Int, sensor: Sensor, value: Float) {
        self.timestamp = timestamp
        self.sensor = sensor
        self.value = value
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(timestamp, forKey: PropertyKey.timestamp)
        coder.encode(sensor, forKey: PropertyKey.sensor)
        coder.encode(value, forKey: PropertyKey.value)
    }
    
    required convenience init?(coder: NSCoder) {
        guard let timestamp = coder.decodeObject(forKey: PropertyKey.timestamp) as? Int else {
            NSLog("Unable to decode timestamp for reading")
            return nil
        }
        guard let sensor = coder.decodeObject(forKey: PropertyKey.sensor) as? Sensor else {
            NSLog("Unable to decode sensor for reading")
            return nil
        }
        guard let value = coder.decodeObject(forKey: PropertyKey.value) as? Float else {
            NSLog("Unable to decode value for reading")
            return nil
        }
        
        self.init(timestamp: timestamp, sensor: sensor, value: value)
    }
    
    struct PropertyKey {
        static let timestamp = "timestamp"
        static let sensor = "sensor"
        static let value = "value"
    }
}
