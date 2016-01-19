//
//  DataSetManager.swift
//  Laser Processor
//
//  Created by Xinhong LIU on 19/1/2016.
//  Copyright © 2016 ParseCool. All rights reserved.
//

import Foundation
import SQLite
import UIKit

class DataSetManager {

    static let dbFile = "laser_v1.0.db"
    static let imageDir = "images"
    
    static func docsDirPath() -> String {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return dirPaths[0]
    }
    
    static func imagesDirPath() -> String {
        return "\(docsDirPath())/\(imageDir)"
    }
    
    var _db: Connection?
    
    var db: Connection {
        get {
            if _db == nil {
                do {
                    let dbFilePath = "\(DataSetManager.docsDirPath())/\(DataSetManager.dbFile)"
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
    
    func saveDataSet(dataSetName: String, baseImage: UIImage, baseImageCreatedTime: NSDate, images: [UIImage], imageCorrelations: [Double], imageCreatedTimes: [NSDate]) {
        // insert DataSet
        let dataSetInsert = dataSet.insert(name <- dataSetName, numberOfImages <- Int64(images.count), createTime <- NSDate())
        var dataSetId: Int64!
        do {
            let rowId = try db.run(dataSetInsert)
            for row in try db.prepare(dataSet.filter(rowid == rowId)) {
                dataSetId = row[id]
            }
        } catch {
            print("Error: \(error)")
        }
        
        let dataSetPath = "\(DataSetManager.imagesDirPath())/\(dataSetId)"
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(dataSetPath) {
            do {
                try fileManager.createDirectoryAtPath(dataSetPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error: \(error)")
            }
        }
        
        // insert images
        for i in 0...(images.count - 1) {
            let imageInsert = self.image.insert(self.dataSetId <- dataSetId, crossCorrelation <- imageCorrelations[i], isBaseImage <- 0, createTime <- imageCreatedTimes[i])
            var imageId: Int64!
            do {
                let rowId = try db.run(imageInsert)
                for row in try db.prepare(self.image.filter(rowid == rowId)) {
                    imageId = row[id]
                }
                let imagePath = "\(dataSetPath)/\(imageId).jpg"
                UIImageJPEGRepresentation(images[i], 1.0)?.writeToFile(imagePath, atomically: true)
            } catch {
                print("Error: \(error)")
            }
        }
        
        // insert baseimage
        let imageInsert = self.image.insert(self.dataSetId <- dataSetId, isBaseImage <- 1, createTime <- baseImageCreatedTime)
        var imageId: Int64!
        do {
            let rowId = try db.run(imageInsert)
            for row in try db.prepare(self.image.filter(rowid == rowId)) {
                imageId = row[id]
            }
            let imagePath = "\(dataSetPath)/\(imageId).jpg"
            UIImageJPEGRepresentation(baseImage, 1.0)?.writeToFile(imagePath, atomically: true)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func fetchAllDataSets() -> [[String: AnyObject]] {
        var dataSets = [[String: AnyObject]]()
        do {
            for row in try db.prepare(self.dataSet.select(name, createTime, numberOfImages)) {
                dataSets.append(["name": row[name]!, "createTime": row[createTime], "numberOfImages": Int(row[numberOfImages])])
            }
        } catch {
            print("Error: \(error)")
        }
        return dataSets
    }

}
