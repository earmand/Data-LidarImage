//
//  Data+LidarImage.swift
//  App
//
//  Created by Daniel Earman on 12/5/19.
//

import Foundation
import AppKit
import MapKit

import DEColor

extension Data {
    var timestamp: String { return String(format:"%0.4f",NSDate().timeIntervalSince1970) }
    
    public func lidarImageScaled(from: MKTileOverlayPath, to: MKTileOverlayPath) -> Data? {
        
        let  gridWidth      = 256
        let  gridHeight     = 256
        let  gridSize       = gridWidth * gridHeight
        
        let zoomScale = to.z - from.z
        if  zoomScale < 0 {
            return nil
        }
        
        if (self.count != gridSize*2) {
            return nil
        }
        
        let scaleFactor = (pow(2,zoomScale) as NSDecimalNumber).intValue
        
        let fromXScaled = from.x * scaleFactor
        let fromYScaled = from.y * scaleFactor
        
        let xIndex = to.x - fromXScaled
        let yIndex = to.y - fromYScaled
        
        if (xIndex < 0) || (xIndex > scaleFactor - 1) {
            print ("x Out of Range")
            return nil
        }
        
        if (yIndex < 0) || (yIndex > scaleFactor - 1) {
            print ("y Out of Range")
            return nil
        }
        
        let fromXstartOffset = xIndex * gridWidth/scaleFactor
        let fromYstartOffset = yIndex * gridHeight/scaleFactor
        
        var  newLidarData = Data.init(count:gridSize*2)
        
        self.withUnsafeBytes { (fromLidarBuffer: UnsafeRawBufferPointer) in
            newLidarData.withUnsafeMutableBytes { (toLidarBuffer: UnsafeMutableRawBufferPointer) in
                
                for row in 0..<gridHeight {
                    for col in 0..<gridWidth {
                        
                        let fromArrayOffset =  (fromYstartOffset + row/scaleFactor) * gridWidth   + (fromXstartOffset + col/scaleFactor)
                        let fromLidarValue = fromLidarBuffer.load(fromByteOffset: fromArrayOffset*2, as: Int16.self)
                        
                        let toArrayOffset =  row * gridWidth + col
                        toLidarBuffer.storeBytes(of: fromLidarValue, toByteOffset: toArrayOffset*2, as: Int16.self)
                    }
                }
            }
        }
        
        return newLidarData
    }
    
    public func lidarbitmapImageRep( gridWidth: Int, gridHeight: Int, baseValue: Int, maxValue: Int, alpha: Int, colors: Int) -> NSBitmapImageRep?{
        
        if (false) { print(String(format:"\(timestamp) \(#function) [\(#line)] : %@","*"))  }
        
        if self.count != gridWidth*gridHeight*2 {
            return nil
        }
        
        var finalBitmapImageRep : NSBitmapImageRep? = nil
        
        self.withUnsafeBytes {  (grid: UnsafePointer<UInt16>) in
            let outputWidth: Int = gridWidth
            let outputHeight: Int = gridHeight
            
            // Setup Graphics Context
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let bytesPerPixel: Int = 4
            let bitsPerComponent: Int = 8
            
            let outputBytesPerRow: Int = bytesPerPixel * outputWidth
            
            let context = CGContext(data: nil, width: outputWidth, height: outputHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: outputBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            
            if (false) { print(String(format:"\(timestamp) \(#function) [\(#line)] : [%i,%i] = %i",0,0,grid[0]))  }
            
            var dataPointer = context?.data     //UnsafeMutableRawPointer?
            
            var color : UInt32 = 0
            //Create Graphics image
            for i in 0..<outputHeight {
                for j in 0..<outputWidth {
                    color = 0
                    
                    let elevation : Int = Int(grid[i * outputWidth + j])
                    let deltaElevation = elevation - baseValue
                    
                    if (deltaElevation > 0) {
                        let floatColor = Float(deltaElevation)/Float(maxValue)
                        
                        //              rgba3ColorGradient
                        color = DEColor.rgba3ColorGradient(from: floatColor, alpha: alpha, colors: colors)
                        //color = DEColor.RGBAMake(r: i, g: j, b: 0, a: 128)
                    }
                    
                    dataPointer?.storeBytes(of: color, as: UInt32.self)
                    dataPointer = dataPointer! + 4
                    //outputPixelArray.append(color)
                    //if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)] : [%i,%i] = %i",i,j,value))  }
                }
            }
            
            let imageRef = context!.makeImage()
            finalBitmapImageRep = NSBitmapImageRep(cgImage: imageRef!)
            
            //free(outputPixels)
            //CGContextRelease(context!)
        }
        
        return finalBitmapImageRep
    }
    
    // NOT USED*********
    public func lidarImage( gridWidth: Int, gridHeight: Int, baseValue: Int, maxValue: Int, alpha: Int, colors: Int) -> NSImage?{
        if (false) { print(String(format:"\(timestamp) \(#function) [\(#line)] : %@","*"))  }
        
        if self.count != gridWidth*gridHeight*2 {
            return nil
        }
        var finalImage : NSImage? = nil
        
        self.withUnsafeBytes {  (grid: UnsafePointer<UInt16>) in
            let outputWidth: Int = gridWidth
            let outputHeight: Int = gridHeight
            
            // Setup Graphics Context
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            
            let bytesPerPixel: Int = 4
            let bitsPerComponent: Int = 8
            
            let outputBytesPerRow: Int = bytesPerPixel * outputWidth
            
            let context = CGContext(data: nil, width: outputWidth, height: outputHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: outputBytesPerRow, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
            
            if (false) { print(String(format:"\(timestamp) \(#function) [\(#line)] : [%i,%i] = %i",0,0,grid[0]))  }
            
            var dataPointer = context?.data     //UnsafeMutableRawPointer?
            
            var color : UInt32 = 0
            //Create Graphics image
            for i in 0..<outputHeight {
                for j in 0..<outputWidth {
                    color = 0
                    
                    let elevation : Int = Int(grid[i * outputWidth + j])
                    let deltaElevation = elevation - baseValue
                    
                    if (deltaElevation > 0) {
                        let floatColor = Float(deltaElevation)/Float(maxValue)
                        
                        color = DEColor.rgba3ColorGradient(from: floatColor, alpha: alpha, colors: colors)
                        //color = DEColor.RGBAMake(r: i, g: j, b: 0, a: 128)
                    }
                    
                    dataPointer?.storeBytes(of: color, as: UInt32.self)
                    dataPointer = dataPointer! + 4
                    //outputPixelArray.append(color)
                    //if (true) { print(String(format:"\(timestamp) \(#function) [\(#line)] : [%i,%i] = %i",i,j,value))  }
                }
            }
            
            let imageRef = context!.makeImage()
            ///// finalImage = NSImage(cgImage: imageRef!)
            
            //free(outputPixels)
            //CGContextRelease(context)
        }
        
        return finalImage
    }
}
