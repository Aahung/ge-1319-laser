//
//  Algorithm.swift
//  Laser Processor
//
//  Created by Xinhong LIU on 3/2/2016.
//  Copyright © 2016 ParseCool. All rights reserved.
//

import UIKit

class Algorithm {
    class func microShiftInnerProduct(baseImagePixels: [UInt32], imagePixels: UnsafePointer<UInt8>, imageRow: Int, imageCol: Int, maxOffset: Int) -> Double {
        var values = [Double]()
        for i in -maxOffset...maxOffset {
            for j in -maxOffset...maxOffset {
                values.append(shiftInnerProduct(baseImagePixels, imagePixels: imagePixels, imageRow: imageRow, imageCol: imageCol, offsetI: i, offsetJ: j))
            }
        }
        return values.maxElement()!
    }
    
    class func nonShiftInnerProduct(baseImagePixels: [UInt32], imagePixels: UnsafePointer<UInt8>, imageRow: Int, imageCol: Int) -> Double {
        return shiftInnerProduct(baseImagePixels, imagePixels: imagePixels, imageRow: imageRow, imageCol: imageCol, offsetI: 0, offsetJ: 0)
    }
    
    class func shiftInnerProduct(baseImagePixels: [UInt32], imagePixels: UnsafePointer<UInt8>, imageRow: Int, imageCol: Int, offsetI: Int, offsetJ: Int) -> Double {
        // 2d inner product
        // algorithm modified from http://stackoverflow.com/a/6801185/2361752
        var dotProduct: UInt64 = 0
        var baseDotProduct: UInt64 = 0
        var imageDotProduct: UInt64 = 0
        for i in 0...(imageRow - 1) {
            for j in 0...(imageCol - 1) {
                let _i = i + offsetI
                let _j = j + offsetJ
                if _i < 0 || _j < 0 || _i >= imageRow || _j >= imageCol {
                    continue
                }
                let index = imageRow * j + i
                let _index = imageRow * _j + _i
                let _index4 = _index * 4 // because there are 4 channels
                dotProduct += UInt64(baseImagePixels[index]) * UInt64(imagePixels[_index4])
                baseDotProduct += UInt64(baseImagePixels[index]) * UInt64(baseImagePixels[index])
                imageDotProduct += UInt64(imagePixels[_index4]) * UInt64(imagePixels[_index4])
            }
        }
        
        return Double(dotProduct) * Double(dotProduct) / Double(baseDotProduct) / Double(imageDotProduct)
    }
}
