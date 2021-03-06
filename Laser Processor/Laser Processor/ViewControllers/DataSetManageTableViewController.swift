//
//  DataSetManageTableViewController.swift
//  Laser Processor
//
//  Created by Xinhong LIU on 19/1/2016.
//  Copyright © 2016 ParseCool. All rights reserved.
//

import UIKit

class DataSetManageTableViewController: UITableViewController {

    var dataSetManager: DataSetManager!
    var dataSets: [DataSet]?
    
    let dateFormatter = NSDateFormatter()
    
    var emptyLabel: UILabel?
    
    override func viewDidLoad() {
        dataSetManager = DataSetManager()
        self.dataSets = dataSetManager.fetchAllDataSets()
        
        super.viewDidLoad()

        initEmptyLabel()
        initTableViewStyles()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.dataSets = dataSetManager.fetchAllDataSets()
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    }

    // MARK: - Setups
    
    func initEmptyLabel() {
        self.emptyLabel = UILabel()
        guard let emptyLabel = self.emptyLabel else {
            print("Failed to create emptyLabel")
            exit(-1)
        }
        emptyLabel.text = "Now you do not have any data sets"
        emptyLabel.textColor = UIColor.blackColor()
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .Center
        emptyLabel.font = UIFont(name: "Palatino-Italic", size: 20)
        emptyLabel.sizeToFit()
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [NSLayoutConstraint(item: emptyLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0), NSLayoutConstraint(item: emptyLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1.0, constant: -20.0)]
        self.view.addSubview(emptyLabel)
        self.view.addConstraints(constraints)
    }
    
    func initTableViewStyles() {
        // remove extra rows
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = self.dataSets!.count
        if numberOfRows > 0 {
            self.emptyLabel?.hidden = true
        } else {
            self.emptyLabel?.hidden = false
        }
        return numberOfRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dataset_cell", forIndexPath: indexPath)

        cell.textLabel?.text = self.dataSets![indexPath.row].name
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.detailTextLabel?.text = "\(dateFormatter.stringFromDate(self.dataSets![indexPath.row].createdTime)), contains \(self.dataSets![indexPath.row].numberOfImages!) images"

        return cell
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var imageCount = 0
        for dataSet in dataSets! {
            imageCount += dataSet.numberOfImages
        }
        return "in total \(self.dataSets!.count) datasets, \(imageCount) images"
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let dataSetId = dataSets![indexPath.row].id
            dataSetManager.deleteDataSet(dataSetId)
            dataSets?.removeAtIndex(indexPath.row)
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "dataset_detail" {
            let destViewController = segue.destinationViewController as! DataSetViewController
            destViewController.dataSet = self.dataSets![(self.tableView.indexPathForSelectedRow!.row)]
        }
    }
}
