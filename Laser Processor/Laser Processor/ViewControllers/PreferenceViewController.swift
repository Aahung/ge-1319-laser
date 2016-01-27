//
//  PreferenceViewController.swift
//  Laser Processor
//
//  Created by Xinhong LIU on 26/1/2016.
//  Copyright © 2016 ParseCool. All rights reserved.
//

import UIKit
import XLForm
import AVFoundation

class PreferenceViewController: XLFormViewController {
    
    var toBeSaved = true
    
    override func viewDidLoad() {
        configureForm()
        
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        if !self.toBeSaved {
            return
        }
        
        // save the values
        let formValues = form.formValues()
        
        Preference.setBaseImageDelay(formValues["delay-base-images"] as! Int)
        Preference.setShootingInterval(formValues["shooting-interval"] as! Int)
        Preference.setPhotoResolution(formValues["photo-resolution"] as! String)
    }

    // MARK: -setup form
    
    func configureForm() {
        var form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor(title: "Preferences") as XLFormDescriptor
        
        // Shutter Setting
        section = XLFormSectionDescriptor.formSectionWithTitle("Shutter Setting") as XLFormSectionDescriptor
        row = XLFormRowDescriptor(tag: "delay-base-images", rowType: XLFormRowDescriptorTypeStepCounter, title: "Base delay (ms)")
        row.value = Preference.getBaseImageDelay()
        row.cellConfigAtConfigure.setObject(5000, forKey: "stepControl.maximumValue")
        row.cellConfigAtConfigure.setObject(1000, forKey: "stepControl.minimumValue")
        row.cellConfigAtConfigure.setObject(100, forKey: "stepControl.stepValue")
        section.addFormRow(row)
        row = XLFormRowDescriptor(tag: "shooting-interval", rowType: XLFormRowDescriptorTypeStepCounter, title: "Shoot Interval (ms)")
        row.value = Preference.getShootingInterval()
        row.cellConfigAtConfigure.setObject(5000, forKey: "stepControl.maximumValue")
        row.cellConfigAtConfigure.setObject(10, forKey: "stepControl.minimumValue")
        row.cellConfigAtConfigure.setObject(10, forKey: "stepControl.stepValue")
        section.addFormRow(row)
        section.footerTitle = "Base delay is the delay (ms) before taking the first base image"
        
        // Photo Setting
        form.addFormSection(section)
        
        section = XLFormSectionDescriptor.formSectionWithTitle("Photo Setting") as XLFormSectionDescriptor
        row = XLFormRowDescriptor(tag: "photo-resolution", rowType: XLFormRowDescriptorTypeSelectorPickerViewInline, title: "Resolution")
        row.value = Preference.getPhotoResolution()
        let options = ["Full Resolution", "1920 x 1080", "1280 x 720", "640 x 480"]
        row.selectorOptions = options
        section.addFormRow(row)
        section.footerTitle = "The resolution is constraint by shutter speed."
        
        form.addFormSection(section)
        
        self.form = form;
    }
    
    @IBAction func saveAndQuit(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func quitWithoutSaving(sender: AnyObject) {
        self.toBeSaved = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
