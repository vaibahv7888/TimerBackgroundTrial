//
//  ViewController.swift
//  TimerBackgroundTrial
//
//  Created by Swapnil Luktuke on 4/13/17.
//  Copyright © 2017 Swapnil Luktuke. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    var centralManager: CBCentralManager?
    var peripherals = Array<CBPeripheral>()
    @IBOutlet weak var tableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        #if BGBLE
//        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func OnReadBLETagsClicked(_ sender: Any) {
        #if BGBLE
//        peripherals.removeAll()
//        self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        #endif
    }
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
//            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            // do something like alert the user that ble is not on
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
            tableView.reloadData()
//            if(!appDelegate.timer.isValid) {
//                appDelegate.timer.invalidate()
//                appDelegate.counter = 0;
//                appDelegate.startTimer()
//                print("In BLE didDiscover update INVALID TIMER")
//                appDelegate.println(s: "Starting timer from BLE didDiscover")
//            }
            print("BLE didDiscover Peripheral: \(peripherals.count). \(peripheral.identifier.uuidString)")
            Logger.println(s: "BLE didDiscover Peripheral: \(peripherals.count). \(peripheral.identifier.uuidString)")
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        let peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = "\(indexPath.row). \(peripheral.identifier.uuidString)"//"\(indexPath.row)"// + peripheral.name!
//        cell.detailTextLabel?.text = "\(indexPath.row):\(peripheral.rssi)"//peripheral.name
//        cell.textLabel?.text = "\(indexPath.row):\(peripheral.services)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
}

