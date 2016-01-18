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
    
    var emptyLabel: UILabel?
    
    override func viewDidLoad() {
        dataSetManager = DataSetManager()
        
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        
        initEmptyLabel()
        initTableViewStyles()
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
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = dataSetManager.numberOfDataSets()
        if numberOfRows > 0 {
            self.emptyLabel?.hidden = true
        } else {
            self.emptyLabel?.hidden = false
        }
        return numberOfRows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dataset_cell", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
