//
//  Logger.swift
//  TimerBackgroundTrial
//
//  Created by Swapnil Luktuke on 4/27/17.
//  Copyright © 2017 Swapnil Luktuke. All rights reserved.
//

import Foundation

struct Logger {
    @available(*, unavailable) private init() {}

    private static var _logFileName = "BGTimer"
    private static var _logFilePath : String?
    
    private static func logFilePath() -> String {
        if nil == _logFilePath {
            var filename = _logFileName
            filename = filename + ".log"
            let paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
            let documentsDirectory: NSString = paths[0] as! NSString
            let logPath: NSString = documentsDirectory.appendingPathComponent(filename) as NSString
            _logFilePath = logPath as String
        }
        return _logFilePath!
    }
    
    static func setLogFileName(name : String) {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        _logFileName = name
    }
    
    static func println(s:String) {
        let timestamp = getCurrentTime()
        let logPath = self.logFilePath()
        var dump = "\n\nStarting new log at : \(timestamp)"
        
        if FileManager.default.fileExists(atPath: logPath) {
            dump =  try! String(contentsOfFile: logPath, encoding: String.Encoding.utf8)
        }
        do {
            // Write to the file
            try  "\(dump)\n\(s)".write(toFile: logPath, atomically: true, encoding: String.Encoding.utf8)
            
        } catch let error as NSError {
            print("Failed writing to log file: \(logPath), Error: " + error.localizedDescription)
        }
    }
}
