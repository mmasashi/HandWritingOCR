//
//  ViewController.swift
//  HandWritingOCR
//
//  Created by Masashi Miyazaki on 6/16/16.
//  Copyright © 2016 Masashi Miyazaki. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate, NSCollectionViewDelegate {

    // Pixcel size for an image on file
    let imageDataSize = Constants.compressedImageSize
    let numberPredictor:NumberPredictor = NumberPredictor()
    
    @IBOutlet weak var drawingView:DrawingView!
    @IBOutlet weak var numberField:NSTextField!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var arrayController: NSArrayController!
    @IBOutlet weak var predictionView: NSTextField!
    @IBOutlet weak var numTrainingData: NSTextField!
    @IBOutlet weak var numTrainedData: NSTextField!
    
    @IBAction func resetClicked(sender: NSButton) {
        reset()
    }
    
    @IBAction func addClicked(sender: NSButton) {
        checkAndAdd()
    }
    
    @IBAction func updateClicked(sender: NSButton) {
        self.updateParameters()
    }
    
    @IBAction func loadSampleClicked(sender: NSButton) {
        var text = ""
        do {
            text = try NSString(contentsOfURL: NSURL(fileURLWithPath: numberPredictor.mlFilePath(Constants.sampleDataFile)), encoding: NSUTF8StringEncoding) as String
        }
        catch { }
        loadImageObjectText(text)
    }
    
    // Callback for x button click
    func deleteClicked(sender: ImageObject) {
        self.arrayController.removeObject(sender)
        self.updateNumOfTrainingData()
    }
    
    // Callback for mouseUp on DrawingView
    func lineDrawn(sender: DrawingView) {
        let imageObject:ImageObject = getImageObject("")
        let predictedNumber = numberPredictor.predict(imageObject)
        predictionView.stringValue = predictedNumber
    }
    
    // Delegate
    override func controlTextDidChange(obj: NSNotification) {
        let number:NSString? = checkAndGetNumber()
        if number == nil || self.drawingView.empty() {
            self.numberField.stringValue = ""
        } else {
            self.checkAndAdd()
        }
    }
    
    func loadImageObjectText(text: String) {
        let tempImageObjectArray = NSMutableArray()
        for line:String in text.componentsSeparatedByString("\n") as [String] {
            if line == "" { continue }
            let imageObject = ImageObject(withCsvText: line)
            tempImageObjectArray.addObject(imageObject)
        }
        self.addImageObjects(tempImageObjectArray)
        self.updateParameters()
    }
    
    func updateParameters() {
        self.numberPredictor.updateOneVsAllThetaWith(self.arrayController.arrangedObjects as! [ImageObject])
        updateNumOfTrainedData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.itemPrototype = self.storyboard?.instantiateControllerWithIdentifier("collectionViewItem") as? NSCollectionViewItem
        self.numberField.delegate = self
        self.drawingView.delegate = self
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func checkAndAdd() -> Bool {
        let number:NSString? = checkAndGetNumber()
        if number == nil { return false }
        let imageObject:ImageObject = getImageObject(number)
        
        self.addImageObject(imageObject)
        self.collectionView.reloadData()
        reset()
        return true
    }
    
    func checkAndGetNumber() -> NSString? {
        var number:String = self.numberField.stringValue
        number = number.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let intNum:Int? = Int(number)
        if intNum == nil {
            return nil
        } else if intNum >= 0 && intNum <= 9 {
            return number
        } else {
            return nil
        }
    }
    
    func reset() {
        self.drawingView.reset()
        self.numberField.stringValue = ""
    }
    
    func getImageObject(number: NSString!) -> ImageObject {
        let image:NSImage? = getScreenshot()
        let resizedImage:NSImage? = imageResize(image!, newSize: imageDataSize)
        let imageObject:ImageObject = ImageObject(image: resizedImage!, number: number)
        return imageObject
    }

    func getScreenshot() -> NSImage {
        let rep = self.view.bitmapImageRepForCachingDisplayInRect(self.drawingView.bounds)!
        self.drawingView.cacheDisplayInRect(self.drawingView.bounds, toBitmapImageRep: rep)
        let image: NSImage = NSImage()
        image.addRepresentation(rep)
        return image
    }
    
    func imageResize(anImage: NSImage, newSize: NSSize) -> NSImage? {
        let screenScale:CGFloat = NSScreen.mainScreen()!.backingScaleFactor
        let expectedSize:NSSize = NSSize(width: newSize.width/screenScale, height: newSize.height/screenScale)
        
        let sourceImage:NSImage = anImage
        if !sourceImage.valid { return nil }
        let smallImage:NSImage = NSImage(size: expectedSize)
        smallImage.lockFocus()
        sourceImage.size = expectedSize
        
        //NSGraphicsContext.currentContext.setImageInterpolation(NSImageInterpolationHigh)
        sourceImage.drawAtPoint(NSZeroPoint, fromRect:CGRectMake(0, 0, expectedSize.width, expectedSize.height), operation: NSCompositingOperation.CompositeCopy, fraction:1.0)
        smallImage.unlockFocus()
        return smallImage
    }
    
    func addImageObject(imageObject: ImageObject) {
        self.addImageObjects([imageObject])
    }
    
    func addImageObjects(imageObjects: NSArray) {
        self.arrayController.addObjects(imageObjects as [AnyObject])
        self.updateNumOfTrainingData()
    }
    
    func updateNumOfTrainingData() {
        let num = String(self.arrayController.arrangedObjects.count)
        self.numTrainingData.stringValue = "Number of training data : \(num)"
    }
    
    func updateNumOfTrainedData() {
        let num = String(self.arrayController.arrangedObjects.count)
        self.numTrainedData.stringValue = "Number of trained data : \(num)"
    }
}

