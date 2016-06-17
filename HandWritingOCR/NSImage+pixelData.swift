//
//  NSImage+pixelData.swift
//  HandWritingOCR
//
//  Created by Masashi Miyazaki on 6/28/16.
//  Copyright © 2016 Masashi Miyazaki. All rights reserved.
//

import AppKit

extension NSImage {
    
    class func createImageFromGrayScaleList(gslist:Array<String>) -> NSImage {
        let height:Int = Int(sqrt(Float(gslist.count)))
        let width:Int = height

        let bmp = NSBitmapImageRep(bitmapDataPlanes: nil,
                                   pixelsWide: width,
                                   pixelsHigh: height,
                                   bitsPerSample: 8,
                                   samplesPerPixel: 3,
                                   hasAlpha: false,
                                   isPlanar: false,
                                   colorSpaceName: NSDeviceRGBColorSpace,
                                   bytesPerRow: 0,
                                   bitsPerPixel: 0)!
        
        for row in 0..<height { // row
            for col in 0..<width { // col
                let index = row * bmp.pixelsHigh + col
                let v:CGFloat = 1.0 - CGFloat(Float(gslist[index])!)
                let color = NSColor(deviceRed: v, green: v, blue: v, alpha: CGFloat(1.0))
                bmp.setColor(color, atX: col, y: row)
            }
        }
        
        let screenScale:CGFloat = NSScreen.mainScreen()!.backingScaleFactor
        let size = NSSize(width: Int(CGFloat(width)/screenScale), height: Int(CGFloat(height)/screenScale))
        let retImage = NSImage(size: size)
        retImage.addRepresentation(bmp)
        return retImage
    }
    
    func grayScalePixelText(separator: String) -> NSMutableString {
        let retString = NSMutableString()
        for pixel in pixelData() {
            retString.appendString(String(pixel.gray) + separator)
        }
        return retString
    }
    
    func pixelData() -> [Pixel] {
        self.lockFocus()
        let bmp = NSBitmapImageRep(focusedViewRect: NSRect(x:0, y:0, width:self.size.width, height:self.size.height))!
        self.unlockFocus()

        var data: UnsafeMutablePointer<UInt8> = bmp.bitmapData
        var r, g, b, a: UInt8
        var pixels: [Pixel] = []
        
        for row in 0..<bmp.pixelsHigh { // row
            for col in 0..<bmp.pixelsWide { // col
                r = data.memory
                data = data.advancedBy(1)
                g = data.memory
                data = data.advancedBy(1)
                b = data.memory
                data = data.advancedBy(1)
                a = data.memory
                data = data.advancedBy(1)
                pixels.append(Pixel(r: r, g: g, b: b, a: a, row: row, col: col))
            }
        }
        return pixels
    }
}

struct Pixel {
    
    var r: Float
    var g: Float
    var b: Float
    var a: Float
    var gray: Float
    var row: Int
    var col: Int
    
    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8, row: Int, col: Int) {
        self.r = Float(r)
        self.g = Float(g)
        self.b = Float(b)
        self.a = Float(a)
        self.gray = Float(255 - ( Int(r) + Int(g) + Int(b) ) / 3) / 255
        self.row = row
        self.col = col
    }
    
    var color: NSColor {
        return NSColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: CGFloat(a/255.0))
    }
    
    var description: String {
        return "RGBA(\(r), \(g), \(b), \(a)) \(gray) at \(row) \(col)"
    }
    
}
