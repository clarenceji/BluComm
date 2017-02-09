//
//  BeaconRViewController.swift
//  BluComm
//
//  Created by Clarence Ji on 7/7/16.
//  Copyright © 2016 Clarence Ji. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

/**
 Determines the distance between the current device and an iBeacon.
 
 This requires two iOS devices, one acting as a "virtual iBeacon" and the other receiving.
 
 This class makes use of CBCentralManager (Core Bluetooth)
 */
class BeaconRViewController: UIViewController, CBCentralManagerDelegate {

    @IBOutlet var txtViewLog: UITextView!
    
    var centralManager: CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [
            CBCentralManagerOptionRestoreIdentifierKey: "com.cjlondon.blucomm.cbcentralmanager"
            ])
        
        
    }
    
    private func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "29B74DA3-3F85-4644-9E96-9D5A3FDEB410")!
        
        let scanOptions = [
            CBCentralManagerScanOptionAllowDuplicatesKey: true
        ]
        let services = [CBUUID(nsuuid: uuid)]
        
        centralManager.scanForPeripherals(withServices: services, options: scanOptions)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 10.0, *) {
            print("central manager did update state: \(central.state.stringValue())")
            if central.state.stringValue() == "poweredOn" {
                startScanning()
            }
        } else {
            // Fallback on earlier versions
            print("central manager did update state")
            if central.state.rawValue == 5 {
                startScanning()
            }
        }
    }
    
    private func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : AnyObject], rssi RSSI: NSNumber) {
        addTextToLog(text: "Discovered, RSSI: \(RSSI.intValue)")
    }

    private func addTextToLog(text: String) {
        
        print(text)
        DispatchQueue.main.async {
            let newString = text + "\n===================\n" + self.txtViewLog.text
            self.txtViewLog.text = newString
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }

}

extension CLProximity {
    
    func stringValue() -> String {
        switch rawValue {
        case 0: return "unknown"
        case 1: return "immediate"
        case 2: return "near"
        case 3: return "far"
        default: return "can't determine"
        }
    }
    
}
