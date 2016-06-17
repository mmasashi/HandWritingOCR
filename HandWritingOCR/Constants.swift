//
//  Constants.swift
//  HandWritingOCR
//
//  Created by Masashi Miyazaki on 7/10/16.
//  Copyright © 2016 Masashi Miyazaki. All rights reserved.
//

import Foundation

struct Constants {
    static let penWidth:CGFloat = 4.0
    static let compressedImageSize:NSSize = NSSize(width: 20, height: 20)
    static let numLabels = 10
    static let numThetaParams = Int(compressedImageSize.width) * Int(compressedImageSize.height) + 1
    static let fileSeparator = ","
    
    static let octavePath = "/usr/local/bin/octave"
    static let sampleDataFile = "ocr_training.csv"
}
