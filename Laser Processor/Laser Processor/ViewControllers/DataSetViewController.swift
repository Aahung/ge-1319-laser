//
//  DataSetViewController.swift
//  Laser Processor
//
//  Created by Xinhong LIU on 20/1/2016.
//  Copyright © 2016 ParseCool. All rights reserved.
//

import UIKit

class DataSetViewController: UIViewController, UITableViewDataSource {

    var dataSet: DataSet!
    
    var baseImages: [DataSetImage]!
    var dataSetImages: [DataSetImage]!
    
    @IBOutlet weak var baseImageView: UIImageView!
    @IBOutlet weak var dataSetName: UILabel!
    @IBOutlet weak var imageCountLabel: UILabel!
    @IBOutlet weak var baseImageTimeLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        let dataSetManager = DataSetManager()
        
        let result = dataSetManager.fetchAllImages(dataSet.id)
        self.baseImages = result.baseImages
        self.dataSetImages = result.images
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.baseImageTimeLabel.text = dateFormatter.stringFromDate(self.baseImages[0].createdTime)
        self.dataSetName.text = self.dataSet.name
        self.imageCountLabel.text = "\(dataSet.numberOfImages) images"
        
        // baseImage
        let baseImageFilePath = "\(DataSetManager.imagesDirPath())/\(self.dataSet.id)/\(self.baseImages[0].id).jpg"
        self.baseImageView.image = UIImage(contentsOfFile: baseImageFilePath)
        
        super.viewDidLoad()
    }

    func configureBaseImage() {
        dataSetName.text = dataSet.name
        imageCountLabel.text = "\(dataSet.numberOfImages) images"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSetImages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("dataset_image_cell") as? DataSetImageTableViewCell
        
        let dataSetImage = dataSetImages[indexPath.row]
        
        cell?.correlationLabel.text = "Correlation: \(String(format: "%.6lf", arguments: [dataSetImage.correlation!]))"
        let deltaSec = dataSetImage.createdTime.timeIntervalSinceDate(baseImages[0].createdTime)
        cell?.timeLabel.text = "\(String(format: "%.3lf", arguments: [deltaSec])) sec(s) later"
        let imageFilePath = "\(DataSetManager.imagesDirPath())/\(self.dataSet.id)/\(dataSetImage.id).jpg"
        cell?.dataSetImageView.image = UIImage(contentsOfFile: imageFilePath)
        
        return cell!
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}
