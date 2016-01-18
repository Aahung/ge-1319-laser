//
//  DataSetManager.swift
//  Laser Processor
//
//  Created by Xinhong LIU on 19/1/2016.
//  Copyright © 2016 ParseCool. All rights reserved.
//

import Foundation
import SQLite

class DataSetManager {

    static let dbFilePath = "laser_v1.0.db"
    static let imageDirPath = "images"
    
    static func docsDirPath() -> String {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return dirPaths[0]
    }
    
    var _db: Connection?
    
    var db: Connection {
        get {
            if _db == nil {
                do {
                    let dbFilePath = "\(DataSetManager.docsDirPath())/\(DataSetManager.dbFilePath)"
                    _db = try Connection(dbFilePath)
                } catch {
                    print("Failed to connect to DB: \(error)")
                }
            }
            return _db!
        }
    }
    
    let dataSet = Table("DataSet")
    let image = Table("Image")
    
    let id = Expression<Int64>("id")
    let name = Expression<String?>("name")
    let numberOfImages = Expression<Int64>("n_images")
    let createTime = Expression<NSDate>("create_time")
    
    //let id = Expression<Int64>("id")
    let dataSetId = Expression<Int64>("data_set_id")
    let isBaseImage = Expression<Int64>("is_base_image")
    let crossCorrelation = Expression<Double?>("cross_corr")
    //let createTime = Expression<Int64>("create_time")
    
    init() {
        
        do {
            // create DataSet Table
            try db.run(dataSet.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .Autoincrement)
                t.column(name)
                t.column(numberOfImages)
                t.column(createTime)
            })
            
        } catch {
            print("Failed to create table DataSet: \(error)")
            exit(-1)
        }
        
        
        do {
            // create Image Table
            try db.run(image.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .Autoincrement)
                t.column(dataSetId, references: dataSet, id)
                t.column(isBaseImage)
                t.column(crossCorrelation)
                t.column(createTime)
            })
        } catch {
            print("Failed to create table Image: \(error)")
            exit(-1)
        }
    }
    
    func numberOfDataSets() -> Int {
        return db.scalar(dataSet.count)
    }
}
