//
//  CBTestViewController.swift
//  BluComm
//
//  Created by Clarence Ji on 7/7/16.
//  Copyright © 2016 Clarence Ji. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class CBTestViewController: UIViewController, CBPeripheralManagerDelegate {

    @IBOutlet var btnStart: UIButton!
    
    private let kAdvertisingData: [String: Any] = [
        CBAdvertisementDataServiceUUIDsKey: [CBUUID(nsuuid: UUID(uuidString: "29B74DA3-3F85-4644-9E96-9D5A3FDEB410")!)]
    ]
    
    private var serviceStarted = false
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject]) {
        
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("Peripheral did start advertising")
        if error != nil {
            print(error!)
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if #available(iOS 10.0, *) {
            print("peripheral did update state: \(peripheral.state.stringValue())")
        } else {
            print("peripheral did update")
        }
    }
    
    @IBAction func btnStartTapped(_ sender: AnyObject) {
        
        if !serviceStarted {
            serviceStarted = true
            DispatchQueue.main.async(execute: { 
                self.btnStart.setTitle("Stop Broadcasting", for: UIControlState())
            })
            
            peripheralManager.startAdvertising(kAdvertisingData)
            
        } else {
            serviceStarted = false
            DispatchQueue.main.async(execute: {
                self.btnStart.setTitle("Start Broadcasting", for: UIControlState())
            })
            
            self.peripheralManager.stopAdvertising()
        }
        
    }

}

@available(iOS 10.0, *)
extension CBManagerState {
    
    func stringValue() -> String {
        
        var string = ""
        
        switch rawValue {
        case 0: string = "unknown"
        case 1: string = "resetting"
        case 2: string = "unsupported"
        case 3: string = "unauthorized"
        case 4: string = "poweredOff"
        case 5: string = "poweredOn"
        default: break
        }
        
        return string
    }
    
}
