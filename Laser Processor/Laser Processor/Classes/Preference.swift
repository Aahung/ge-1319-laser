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
let shootingIntervalKey = DefaultsKey<Int?>("shooting-interval")
let photoResolutionPresetKey = DefaultsKey<String?>("photo-resolution-preset")

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
    
    class func getShootingInterval() -> Int {
        if let value = Defaults[shootingIntervalKey] {
            return value
        }
        Defaults[shootingIntervalKey] = 1000
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
}
