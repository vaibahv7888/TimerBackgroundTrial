//
//  DataSyncManager.swift
//  TimerBackgroundTrial
//
//  Created by Swapnil Luktuke on 4/27/17.
//  Copyright © 2017 Swapnil Luktuke. All rights reserved.
//

import Foundation
import UIKit

func performFetchOperation(completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    let urlSession = URLSession.shared
    
    let task : URLSessionDataTask = urlSession.dataTask(with: URL(string: "https://jsonplaceholder.typicode.com/posts/1")!) { (data, response, error) in
        var logData = "Background fetch"
        var fetchResult : UIBackgroundFetchResult = .noData
        if let downloadError = error {
            print("Downloaded error : \(downloadError)")
            logData = logData + " | Error : " + downloadError.localizedDescription
            fetchResult = .failed
        }
        else if let downloadedData = data {
            print("Downloaded data : \(downloadedData)")
            logData = logData + " | Data : \(downloadedData)"
            fetchResult = .newData
        }
        else {
            print("No data")
            logData = logData + " | No data"
        }
        Logger.println(s: "\(getCurrentTime()) | \(logData)")
        completionHandler(fetchResult)
    }
    task.resume()

}
