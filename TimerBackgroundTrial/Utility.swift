//
//  Utility.swift
//  TimerBackgroundTrial
//
//  Created by Swapnil Luktuke on 4/27/17.
//  Copyright © 2017 Swapnil Luktuke. All rights reserved.
//

import Foundation

public func getCurrentTime() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd HH.mm.ss"    //"HH.mm dd.MM.yyyy"
    let result = formatter.string(from: date)
    return result
}
