//
//  Document.swift
//  HandWritingOCR
//
//  Created by Masashi Miyazaki on 6/16/16.
//  Copyright © 2016 Masashi Miyazaki. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    
    var tempImageObjectText:NSString?
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
        self.addWindowController(windowController)
        
        // Load loaded data if exists
        if self.tempImageObjectText != nil {
            self.viewController().loadImageObjectText(self.tempImageObjectText as! String)
            self.tempImageObjectText = nil
        }
    }

    override func dataOfType(typeName: String) throws -> NSData {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        //throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)

        let retString:NSMutableString = NSMutableString()
        for imageObject:ImageObject in self.arrayController().arrangedObjects as! [ImageObject] {
            retString.appendString((imageObject.grayScaleTextData(Constants.fileSeparator) as String) + "\n")
        }
        return retString.dataUsingEncoding(NSUTF8StringEncoding)!
    }

    override func readFromData(data: NSData, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        //throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        
        self.tempImageObjectText = NSString(data: data, encoding:NSUTF8StringEncoding)!
    }
    
    func arrayController() -> NSArrayController {
        return self.viewController().arrayController!
    }
    
    func viewController() -> ViewController {
        return ((self.windowControllers.first?.contentViewController)! as? ViewController)!
    }

}

