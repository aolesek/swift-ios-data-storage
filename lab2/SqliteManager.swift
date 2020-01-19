//
//  SqliteManager.swift
//  lab2
//
//  Created by arek on 19/01/2020.
//  Copyright © 2020 aolesek. All rights reserved.
//

import Foundation

class SqliteManager {
    
    static private let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    static private let dbFilePath = NSURL(fileURLWithPath: SqliteManager.docDir).appendingPathComponent("demo.db")?.path
    private var db: OpaquePointer? = nil
    private var st: OpaquePointer? = nil
    
    init() {        trySql(sqlite3_open(SqliteManager.dbFilePath, &db))    }
    
    deinit {        sqlite3_close(db)    }
    
    //MARK: Generating
    func generateData(readingsNumber: Int) -> TimeInterval {
        let startTime = Date()
        
        // generating
        var sensors: [SqlSensor] = []
        var readings: [SqlReading] = []
        Utils.generateSqlSensorsAndReadings(&sensors, readingsNumber, &readings)
        
        trySql(sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil))
        generateScheme()
        insertSensors(sensors: sensors)
        insertReadings(readings: readings)
        trySql(sqlite3_exec(db, "COMMIT TRANSACTION", nil, nil, nil))
        
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        
        print("Sql generate finished in \(measuredTime)")
        return measuredTime
    }
    
    private func generateScheme() {
        let tablesSql = """
            drop table if exists readings;
            drop table if exists sensors;

            create table sensors (
                id integer primary key,
                name varchar(10),
                desc varchar(100));

            create table readings (
                id integer primary key,
                timestamp integer,
                value real,
                sensor integer,
                foreign key(sensor) references sensors(id));
            """
        
        trySql(sqlite3_exec(db, tablesSql, nil, nil, nil))
    }
    
    private func insertSensors(sensors: [SqlSensor]) {
        let insertSensor = "INSERT INTO sensors (name, desc) VALUES (?, ?);"
        trySql(sqlite3_prepare_v2(db, insertSensor, -1, &st, nil))
        
        sensors.forEach({ (sensor) in
            sqlite3_reset(st)
            trySql(sqlite3_bind_text(st, 1, sensor.name, -1, nil))
            trySql(sqlite3_bind_text(st, 2, sensor.desc, -1, nil))
            sqlite3_step(st)
        })
        
        trySql(sqlite3_finalize(st))
    }
    
    private func insertReadings(readings: [SqlReading]) {
        let insertSensor = "INSERT INTO readings (id, timestamp, value, sensor) VALUES (?, ?, ?, ?);"
        trySql(sqlite3_prepare_v2(db, insertSensor, -1, &st, nil))
        
        readings.forEach({ (reading) in
            sqlite3_reset(st)
            
            trySql( sqlite3_bind_int(st, 1, Int32(reading.id)))
            trySql( sqlite3_bind_int(st, 2, Int32(reading.timestamp)))
            trySql( sqlite3_bind_double(st, 3, Double(reading.value)))
            trySql( sqlite3_bind_int(st, 4, Int32(reading.sensor)))
            
            sqlite3_step(st)
        })
        
        trySql(sqlite3_finalize(st))
    }
    
    //MARK: Queries
    
    func sqlMinMax() -> (TimeInterval, Int?, Int?) {
        let startTime = Date()
        
        let timestampMinMax = "select min(timestamp), max(timestamp) from readings;"
        trySql(sqlite3_prepare_v2(db, timestampMinMax, -1, &st, nil))
        
        var min: Int? = nil
        var max: Int? = nil
        
        if sqlite3_step(st) == SQLITE_ROW {
            min = Int(sqlite3_column_int(st, 0))
            max = Int(sqlite3_column_int(st, 1))
        } else {
            print("Unable to get minmax - sql query should return SQLITE_ROW!")
        }
        trySql(sqlite3_finalize(st))
        
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        
        print("Sql minmax finished in \(measuredTime)")
        return (measuredTime, min, max)
    }
    
    //MARK: Avg
    
    func sqlAvg() -> (TimeInterval, Double?){
        let startTime = Date()
        
        let avgSql = "select avg(value) from readings;"
        trySql(sqlite3_prepare_v2(db, avgSql, -1, &st, nil))
        
        var avg: Double? = nil
        
        if sqlite3_step(st) == SQLITE_ROW {
            avg = Double(sqlite3_column_double(st, 0))
        } else {
            print("Unable to get avg value - sql query should return SQLITE_ROW!")
        }
        trySql(sqlite3_finalize(st))
        
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        
        print("Sql avg finished in \(measuredTime)")
        return (measuredTime, avg)
    }
    
    //MARK: Avg per sensor
    func sqlAvgPerSensor() -> (TimeInterval, [(Int, Double)]) {
        let startTime = Date()
        
        let avgSql = "select sensor, avg(value) from readings group by sensor;"
        trySql(sqlite3_prepare_v2(db, avgSql, -1, &st, nil))
        
        var result: [(Int, Double)] = []
        var row = 0
        while sqlite3_step(st) == SQLITE_ROW {
            row += 1
            let sensor = sqlite3_column_int(st, 0)
            let avg = sqlite3_column_double(st, 1)
            result.append((Int(sensor), avg))
        }
        trySql(sqlite3_finalize(st))
        
        let finishTime = Date()
        let measuredTime = finishTime.timeIntervalSince(startTime)
        
        print("Sql avg per sensor finished in \(measuredTime)")
        return (measuredTime, result)
    }
    
    //MARK: Utils
    func trySql(_ res: Int32) {
        if (res != SQLITE_OK) {
            sqlite3_close(db)
            print(String(format:"Error: SQLite returned non SQLITE_OK code. %d", res))
        }
    }
}
