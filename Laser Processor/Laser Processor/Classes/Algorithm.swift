//
//  Algorithm.swift
//  Laser Processor
//
//  Created by Xinhong LIU on 3/2/2016.
//  Copyright © 2016 ParseCool. All rights reserved.
//
// GPU part take inspiration from 
// http://memkite.com/blog/2014/12/15/data-parallel-programming-with-metal-and-swift-for-iphoneipad-gpu/

import UIKit
import MetalKit

class Algorithm {
    
    let device = MTLCreateSystemDefaultDevice()!
    var defaultLibrary: MTLLibrary!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLComputePipelineState!
    
    init() {
        print("maxThreadsPerThreadgroup: \(device.maxThreadsPerThreadgroup)");
        defaultLibrary = device.newDefaultLibrary()
        commandQueue = device.newCommandQueue()
        let innerProductProgram = defaultLibrary.newFunctionWithName("innerProduct")
        do {
            pipelineState = try device.newComputePipelineStateWithFunction(innerProductProgram!)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func microShiftInnerProductGPU(baseImagePixels: [Float], imagePixels: UnsafePointer<UInt8>, imageRow: Int, imageCol: Int, maxOffset: Int) -> Float {
        
        var values = [Float]()
        for i in -maxOffset...maxOffset {
            for j in -maxOffset...maxOffset {
                values.append(shiftInnerProductGPU(baseImagePixels, imagePixels: imagePixels, imageRow: imageRow, imageCol: imageCol, offsetI: i, offsetJ: j))
            }
        }
        print("\(values)")
        return values.maxElement()!
        
    }
    
    func shiftInnerProductGPU(baseImagePixels: [Float], imagePixels: UnsafePointer<UInt8>, imageRow: Int, imageCol: Int, offsetI: Int, offsetJ: Int) -> Float {
        
        let commandBuffer = commandQueue.commandBuffer()
        let computeCommandEncoder = commandBuffer.computeCommandEncoder()
        computeCommandEncoder.setComputePipelineState(pipelineState)
        
        let baseImagePixelsByteLength = baseImagePixels.count * sizeofValue(baseImagePixels[0])
        let baseImagePixelsBuffer = device.newBufferWithBytes(baseImagePixels, length: baseImagePixelsByteLength, options: .OptionCPUCacheModeDefault)
        computeCommandEncoder.setBuffer(baseImagePixelsBuffer, offset: 0, atIndex: 0)
        
        let imagePixelsByteLength = 4 * imageRow * imageCol * sizeof(UInt8)
        let imagePixelsBuffer = device.newBufferWithBytes(imagePixels, length: imagePixelsByteLength, options: .OptionCPUCacheModeDefault)
        computeCommandEncoder.setBuffer(imagePixelsBuffer, offset: 0, atIndex: 1)
        
        let otherParametersByteLength = 4 * sizeof(Int32)
        var otherParameters = [Int32](count: 4, repeatedValue: 0)
        otherParameters[0] = Int32(imageRow)
        otherParameters[1] = Int32(imageCol)
        otherParameters[2] = Int32(offsetI)
        otherParameters[3] = Int32(offsetJ)
        let otherParametersBuffer = device.newBufferWithBytes(otherParameters, length: otherParametersByteLength, options: .CPUCacheModeDefaultCache)
        computeCommandEncoder.setBuffer(otherParametersBuffer, offset: 0, atIndex: 2)
        
        let dotProductByteLength = imageRow * imageCol * sizeof(Float)
        let dotProduct = [Float](count: imageRow * imageCol, repeatedValue: 0.0)
        let dotProductBuffer = device.newBufferWithBytes(dotProduct, length: dotProductByteLength, options: .CPUCacheModeWriteCombined)
        computeCommandEncoder.setBuffer(dotProductBuffer, offset: 0, atIndex: 3)
        
        let baseDotProductByteLength = imageRow * imageCol * sizeof(Float)
        let baseDotProduct = [Float](count: imageRow * imageCol, repeatedValue: 0.0)
        let baseDotProductBuffer = device.newBufferWithBytes(baseDotProduct, length: baseDotProductByteLength, options: .CPUCacheModeWriteCombined)
        computeCommandEncoder.setBuffer(baseDotProductBuffer, offset: 0, atIndex: 4)
        
        let imageDotProductByteLength = imageRow * imageCol * sizeof(Float)
        let imageDotProduct = [Float](count: imageRow * imageCol, repeatedValue: 0.0)
        let imageDotProductBuffer = device.newBufferWithBytes(imageDotProduct, length: imageDotProductByteLength, options: .CPUCacheModeWriteCombined)
        computeCommandEncoder.setBuffer(imageDotProductBuffer, offset: 0, atIndex: 5)
        
        let outputValuesByteLength = 1 * sizeof(Float)
        let outputValues = [Float](count: 1, repeatedValue: 0.0)
        let outputValuesBuffer = device.newBufferWithBytes(outputValues, length: outputValuesByteLength, options: .CPUCacheModeDefaultCache)
        //        let outputValuesBuffer = device.newBufferWithBytes(outputValues, length: outputValuesByteLength, options: .StorageModePrivate)
        computeCommandEncoder.setBuffer(outputValuesBuffer, offset: 0, atIndex: 6)
        
        // hardcoded to 32 for now (recommendation: read about threadExecutionWidth)
        let threadsPerGroup = MTLSize(width:32, height:1, depth:1)
        let numThreadgroups = MTLSize(width:(baseImagePixels.count + 31) / 32, height:1, depth:1)
        computeCommandEncoder.dispatchThreadgroups(numThreadgroups, threadsPerThreadgroup: threadsPerGroup)
        
        computeCommandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        let data = NSData(bytesNoCopy: outputValuesBuffer.contents(),
            length: outputValues.count * sizeof(Float), freeWhenDone: false)
        // b. prepare Swift array large enough to receive data from GPU
        var finalResultArray = [Float](count: outputValues.count, repeatedValue: 0.0)
        
        // c. get data from GPU into Swift array
        data.getBytes(&finalResultArray, length:outputValues.count * sizeof(Float))
        
        
        return finalResultArray[0]
    }
    
    class func microShiftInnerProduct(baseImagePixels: [Float], imagePixels: UnsafePointer<UInt8>, imageRow: Int, imageCol: Int, maxOffset: Int) -> Float {
        var values = [Float]()
        for i in -maxOffset...maxOffset {
            for j in -maxOffset...maxOffset {
                values.append(shiftInnerProduct(baseImagePixels, imagePixels: imagePixels, imageRow: imageRow, imageCol: imageCol, offsetI: i, offsetJ: j))
            }
        }
        print("\(values)")
        return values.maxElement()!
    }
    
    class func nonShiftInnerProduct(baseImagePixels: [Float], imagePixels: UnsafePointer<UInt8>, imageRow: Int, imageCol: Int) -> Float {
        return shiftInnerProduct(baseImagePixels, imagePixels: imagePixels, imageRow: imageRow, imageCol: imageCol, offsetI: 0, offsetJ: 0)
    }
    
    class func shiftInnerProduct(baseImagePixels: [Float], imagePixels: UnsafePointer<UInt8>, imageRow: Int, imageCol: Int, offsetI: Int, offsetJ: Int) -> Float {
        // 2d inner product
        // algorithm modified from http://stackoverflow.com/a/6801185/2361752
        var dotProduct: Float = 0
        var baseDotProduct: Float = 0
        var imageDotProduct: Float = 0
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
                dotProduct += Float(baseImagePixels[index]) * Float(imagePixels[_index4])
                baseDotProduct += Float(baseImagePixels[index]) * Float(baseImagePixels[index])
                imageDotProduct += Float(imagePixels[_index4]) * Float(imagePixels[_index4])
            }
        }
        
        return dotProduct * dotProduct / baseDotProduct / imageDotProduct
    }
}
