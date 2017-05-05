//
//  LogViewController.swift
//  TimerBackgroundTrial
//
//  Created by Swapnil Luktuke on 5/5/17.
//  Copyright © 2017 Swapnil Luktuke. All rights reserved.
//

import Foundation
import UIKit

class LogViewController : UIViewController
{
    @IBOutlet weak var logWebView: UIWebView!
    
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLog()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshLog()
    }

    // MARK: IBActions
    
    @IBAction func tapOnRefresh(_ sender: Any) {
        refreshLog()
    }
    
    @IBAction func tapOnDelete(_ sender: Any) {
        showLogDeleteConfirmation()
    }
    
    // MARK: Log display
    
    func displayLog() {
        logWebView.loadRequest(URLRequest(url: URL(fileURLWithPath: Logger.logFilePath())))
    }
    
    func refreshLog() {
        logWebView.reload()
    }

    
    // MARK: Log deletion
    
    func showLogDeleteConfirmation() {
        let alertController = UIAlertController(title: "Clear log", message: "Are you sure you want to clear the log. This is permanant and cannot be undone.", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.clearLog()
        }
        alertController.addAction(deleteAction)
        
        self.present(alertController, animated: true) { 
            
        }
    }
    
    func clearLog() {
        Logger.clearLog(completionHandler: {
            refreshLog();
        })
    }

}
