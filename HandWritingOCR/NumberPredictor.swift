//
//  NumberPredictor.swift
//  HandWritingOCR
//
//  Created by Masashi Miyazaki on 7/2/16.
//  Copyright © 2016 Masashi Miyazaki. All rights reserved.
//

import Foundation

class NumberPredictor {
    
    var oneVsAllTheta =
        Array(count: Constants.numLabels, repeatedValue:
            Array(count: Constants.numThetaParams, repeatedValue: Float(0.0)))
    
    init() {
        // Set random theta as default value
        for d in 0...(oneVsAllTheta.count - 1) {
            for i in 0...(oneVsAllTheta[d].count - 1) {
                oneVsAllTheta[d][i] = Float(arc4random_uniform(2147483648)) / Float(2147483648);
            }
        }
    }
    
    // Setting learnning parameters
    
    func updateOneVsAllThetaWith(imageObjects: [ImageObject]) {
        if imageObjects.count == 0 { return }
        let tmpDataPath = saveDataCsvText(imageObjects)
        let tmpThetaPath = createTempFilePath()!.path!
        runUpdateTheta(tmpDataPath, thetaPath:tmpThetaPath)
        setOneVsAllThetaFromCsvFile(tmpThetaPath)
    }
    
    func setOneVsAllThetaFromCsvFile(filePath: String) {
        var text = ""
        do {
            text = try NSString(contentsOfURL: NSURL(fileURLWithPath: filePath), encoding: NSUTF8StringEncoding) as String
        }
        catch {  }
        setOneVsAllThetaFromCsv(text)
    }
    
    func setOneVsAllThetaFromCsv(text: String) {
        var d = 0
        var i = 0
        for line:String in text.componentsSeparatedByString("\n") as [String] {
            if line == "" { continue }
            i = 0
            for element:String in line.componentsSeparatedByString(Constants.fileSeparator) as [String] {
                if element == "" || element == "\n" { continue }
                oneVsAllTheta[d][i] = Float(element)!
                i += 1
            }
            d += 1
        }
    }
    
    func saveThetaCsvText() -> String {
        let tmpFileUrl = createTempFilePath()
        let csvText:NSMutableString = NSMutableString()
        for aryPerLabel in oneVsAllTheta {
            for element:Float in aryPerLabel {
                csvText.appendString(String(element))
                csvText.appendString(Constants.fileSeparator)
            }
            csvText.deleteCharactersInRange(NSRange(location: csvText.length - 1, length: 1))
            csvText.appendString("\n")
        }
        do {
            try csvText.writeToURL(tmpFileUrl!, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            return ""
        }
        return (tmpFileUrl?.path)!
    }
    
    // Predict a number for the given picture
    
    func predict(imageObject: ImageObject) -> String {
        let tmpDataPath = saveDataCsvText([imageObject])
        let tmpThetaPath = saveThetaCsvText()
        return runPredict(tmpDataPath, thetaPath:tmpThetaPath)
    }
    
    func saveDataCsvText(imageObjects: [ImageObject]) -> String {
        let tmpFileUrl = createTempFilePath()
        let csvText:NSMutableString = NSMutableString()
        for imageObject:ImageObject in imageObjects {
            csvText.appendString(imageObject.grayScaleTextData(Constants.fileSeparator) as String)
            csvText.appendString("\n")
        }
        do {
            try csvText.writeToURL(tmpFileUrl!, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            return ""
        }
        return (tmpFileUrl?.path)!
    }
    
    func createTempFilePath() -> NSURL? {
        let directory = NSTemporaryDirectory()
        let fileName = NSUUID().UUIDString
        
        let fullURL:NSURL? = NSURL.fileURLWithPathComponents([directory, fileName])
        return fullURL
    }

    func runPredict(dataPath: String, thetaPath: String) -> String {
        let octFilePath:String = mlFilePath("run_predict.m")
        return CommandUtil.octave(octFilePath, arguments: [dataPath, thetaPath])
    }
    
    func runUpdateTheta(dataPath: String, thetaPath: String) -> String {
        let octFilePath:String = mlFilePath("run_update_theta.m")
        return CommandUtil.octave(octFilePath, arguments: [dataPath, thetaPath])
    }
    
    func mlFilePath(filePath: String) -> String {
        let baseMLPath:String = NSBundle.mainBundle().pathForResource("ML", ofType: "")!
        if filePath == "" {
            return baseMLPath
        } else {
            return "\(baseMLPath)/\(filePath)"
        }
    }
}