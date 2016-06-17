//
//  ImageObject.swift
//  HandWritingOCR
//
//  Created by Masashi Miyazaki on 6/22/16.
//  Copyright © 2016 Masashi Miyazaki. All rights reserved.
//

import Cocoa

class ImageObject: NSObject {
    var image: NSImage
    var number: NSString
    
    init (image: NSImage, number: NSString) {
        self.image = image
        self.number = number
    }
    
    init (withCsvText csvText:NSString) {
        let ary:Array<String> = Array(csvText.componentsSeparatedByString(Constants.fileSeparator))
        let pixelTextList:Array<String> = Array(ary[0...(ary.count-2)])
        self.number = String(ary[ary.count-1])
        self.image = NSImage.createImageFromGrayScaleList(pixelTextList)
    }
    
    func grayScaleTextData(separator: String) -> NSMutableString {
        let retString = self.image.grayScalePixelText(separator)
        retString.appendString(String(self.number))
        return retString
    }

    // For debugging
    
    func dumpTextData() {
        NSLog(String(self.grayScaleTextData(Constants.fileSeparator)))
    }
    
    func dumpPixels() {
        for pixel:Pixel in self.image.pixelData() {
            NSLog(pixel.description)
        }
    }

}