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
        Preference.setBaseImageCount(formValues["base-images-count"] as! Int)
        Preference.setImageCount(formValues["images-count"] as! Int)
        Preference.setShootingInterval(formValues["shooting-interval"] as! Int)
        Preference.setPhotoResolution(formValues["photo-resolution"] as! String)
        Preference.setMaxShifting(formValues["max-shifting"] as! Int)
        Preference.setCalculationDevice(formValues["calculation-device"] as! String)
        Preference.setSamplePercentage(formValues["sample-percentage"] as! Int)
        Preference.setPlotInterval(formValues["plot-interval"] as! Int)
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
        row = XLFormRowDescriptor(tag: "base-images-count", rowType: XLFormRowDescriptorTypeStepCounter, title: "Base image n")
        row.value = Preference.getBaseImageCount()
        row.cellConfigAtConfigure.setObject(5, forKey: "stepControl.maximumValue")
        row.cellConfigAtConfigure.setObject(1, forKey: "stepControl.minimumValue")
        row.cellConfigAtConfigure.setObject(1, forKey: "stepControl.stepValue")
        section.addFormRow(row)
        row = XLFormRowDescriptor(tag: "images-count", rowType: XLFormRowDescriptorTypeStepCounter, title: "Image n")
        row.value = Preference.getImageCount()
        row.cellConfigAtConfigure.setObject(400, forKey: "stepControl.maximumValue")
        row.cellConfigAtConfigure.setObject(1, forKey: "stepControl.minimumValue")
        row.cellConfigAtConfigure.setObject(1, forKey: "stepControl.stepValue")
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
        var options = ["Full Resolution", "1920 x 1080", "1280 x 720", "640 x 480"]
        row.selectorOptions = options
        section.addFormRow(row)
        section.footerTitle = "The resolution is constraint by shutter speed."
        
        form.addFormSection(section)
        
        // Calculation Settings
        section = XLFormSectionDescriptor.formSectionWithTitle("Calculation Setting") as XLFormSectionDescriptor
        row = XLFormRowDescriptor(tag: "max-shifting", rowType: XLFormRowDescriptorTypeStepCounter, title: "Max Shift (px)")
        row.value = Preference.getMaxShifting()
        row.cellConfigAtConfigure.setObject(10, forKey: "stepControl.maximumValue")
        row.cellConfigAtConfigure.setObject(0, forKey: "stepControl.minimumValue")
        row.cellConfigAtConfigure.setObject(1, forKey: "stepControl.stepValue")
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "calculation-device", rowType: XLFormRowDescriptorTypeSelectorPickerViewInline, title: "Calculation Device")
        row.value = Preference.getCalculationDevice()
        options = ["CPU", "GPU", "OpenCV"]
        row.selectorOptions = options
        section.addFormRow(row)
        
        row = XLFormRowDescriptor(tag: "sample-percentage", rowType: XLFormRowDescriptorTypeStepCounter, title: "Sampling Percentage")
        row.value = Preference.getSamplePercentage()
        row.cellConfigAtConfigure.setObject(100, forKey: "stepControl.maximumValue")
        row.cellConfigAtConfigure.setObject(1, forKey: "stepControl.minimumValue")
        row.cellConfigAtConfigure.setObject(1, forKey: "stepControl.stepValue")
        section.addFormRow(row)
        
        form.addFormSection(section)
        
        // Plot Settings
        section = XLFormSectionDescriptor.formSectionWithTitle("Plot Setting") as XLFormSectionDescriptor
        
        row = XLFormRowDescriptor(tag: "plot-interval", rowType: XLFormRowDescriptorTypeStepCounter, title: "Plot Interval")
        row.value = Preference.getPlotInterval()
        row.cellConfigAtConfigure.setObject(500, forKey: "stepControl.maximumValue")
        row.cellConfigAtConfigure.setObject(1, forKey: "stepControl.minimumValue")
        row.cellConfigAtConfigure.setObject(1, forKey: "stepControl.stepValue")
        section.addFormRow(row)
        
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
