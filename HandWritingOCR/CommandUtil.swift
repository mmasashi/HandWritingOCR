//
//  CommandUtil.swift
//  HandWritingOCR
//
//  Created by Masashi Miyazaki on 7/2/16.
//  Copyright © 2016 Masashi Miyazaki. All rights reserved.
//

import Foundation

class CommandUtil {

    // http://stackoverflow.com/a/31510860/1008778
    class func shell(launchPath: String, arguments: [String]) -> String
    {
        let task = NSTask()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: NSUTF8StringEncoding)!
        if output.characters.count > 0 {
            return output.substringToIndex(output.endIndex.advancedBy(-1))
            
        }
        return output
    }
    
    class func bash(command: String, arguments: [String]) -> String {
        let whichPathForCommand = shell("/bin/bash", arguments: [ "-l", "-c", "which \(command)" ])
        return shell(whichPathForCommand, arguments: arguments)
    }
    
    class func octave(octaveFilePath: String, arguments: [String]) -> String {
        let octaveCmd:String = Constants.octavePath
        return shell(octaveCmd, arguments:[octaveFilePath] + arguments)
    }
}