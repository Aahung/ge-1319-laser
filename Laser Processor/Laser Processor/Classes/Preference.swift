//
//  Preference.swift
//  Laser Processor
//
//  Created by Xinhong LIU on 27/1/2016.
//  Copyright © 2016 ParseCool. All rights reserved.
//

import SwiftyUserDefaults
import AVFoundation

let delayBaseImageKey = DefaultsKey<Int?>("delay-base-images")
let baseImageCountKey = DefaultsKey<Int?>("base-image-count")
let shootingIntervalKey = DefaultsKey<Int?>("shooting-interval")
let photoResolutionPresetKey = DefaultsKey<String?>("photo-resolution-preset")
let maxShiftingKey = DefaultsKey<Int?>("max-shifting")
let calculationDevicekey = DefaultsKey<String?>("calculation-device")
let imageCountKey = DefaultsKey<Int?>("image-count")
let samplePercentageKey = DefaultsKey<Int?>("sample-percentage")
let plotIntervalKey = DefaultsKey<Int?>("plot-interval")

class Preference: NSObject {
    class func getBaseImageDelay() -> Int {
        if let value = Defaults[delayBaseImageKey] {
            return value
        }
        Defaults[delayBaseImageKey] = 1000
        return getBaseImageDelay()
    }
    
    class func setBaseImageDelay(value: Int) {
        Defaults[delayBaseImageKey] = value
    }
    
    class func getBaseImageCount() -> Int {
        if let value = Defaults[baseImageCountKey] {
            return value
        }
        Defaults[baseImageCountKey] = 3
        return getBaseImageCount()
    }
    
    class func setBaseImageCount(value: Int) {
        Defaults[baseImageCountKey] = value
    }
    
    class func getImageCount() -> Int {
        if let value = Defaults[imageCountKey] {
            return value
        }
        Defaults[imageCountKey] = 100
        return getImageCount()
    }
    
    class func setImageCount(value: Int) {
        Defaults[imageCountKey] = value
    }
    
    class func getShootingInterval() -> Int {
        if let value = Defaults[shootingIntervalKey] {
            return value
        }
        Defaults[shootingIntervalKey] = 100
        return getShootingInterval()
    }
    
    class func setShootingInterval(value: Int) {
        Defaults[shootingIntervalKey] = value
    }
    
    class func getShootingIntervalAsSeconds() -> Double {
        let ms = Double(getShootingInterval())
        return ms / 1000.0
    }
    
    class func getPhotoResolution() -> String {
        if let value = Defaults[photoResolutionPresetKey] {
            return value
        }
        Defaults[photoResolutionPresetKey] = "Full Resolution"
        return getPhotoResolution()
    }
    
    class func setPhotoResolution(value: String) {
        Defaults[photoResolutionPresetKey] = value
    }
    
    class func getPhotoResolutionAsPreset() -> String {
        let dict = ["Full Resolution": AVCaptureSessionPresetPhoto,
            "1920 x 1080": AVCaptureSessionPreset1920x1080, "1280 x 720": AVCaptureSessionPreset1280x720, "640 x 480": AVCaptureSessionPreset640x480]
        return dict[getPhotoResolution() as String]!
    }
    
    class func getMaxShifting() -> Int {
        if let value = Defaults[maxShiftingKey] {
            return value
        }
        Defaults[maxShiftingKey] = 2
        return getMaxShifting()
    }
    
    class func setMaxShifting(value: Int) {
        Defaults[maxShiftingKey] = value
    }
    
    class func getCalculationDevice() -> String {
        if let value = Defaults[calculationDevicekey] {
            return value
        }
        Defaults[calculationDevicekey] = "CPU"
        return getCalculationDevice()
    }
    
    class func setCalculationDevice(value: String) {
        Defaults[calculationDevicekey] = value
    }
    
    class func getSamplePercentage() -> Int {
        if let value = Defaults[samplePercentageKey] {
            return value
        }
        Defaults[samplePercentageKey] = 10
        return getSamplePercentage()
    }
    
    class func setSamplePercentage(value: Int) {
        Defaults[samplePercentageKey] = value
    }
    
    class func getPlotInterval() -> Int {
        if let value = Defaults[plotIntervalKey] {
            return value
        }
        Defaults[plotIntervalKey] = 10
        return getPlotInterval()
    }
    
    class func setPlotInterval(value: Int) {
        Defaults[plotIntervalKey] = value
    }
}
