//
//  BeaconViewController.swift
//  BluComm
//
//  Created by Clarence Ji on 7/7/16.
//  Copyright © 2016 Clarence Ji. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class BeaconViewController: UIViewController, CBPeripheralManagerDelegate {

    @IBOutlet var btnStart: UIButton!
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnStartTapped(_ sender: AnyObject) {
        
        if btnStart.titleLabel?.text == "Start Virtual iBeacon" {
            initBeacon()
            DispatchQueue.main.async(execute: { 
                self.btnStart.setTitle("Stop Virtual iBeacon", for: UIControlState())
            })
        } else {
            peripheralManager.stopAdvertising()
            DispatchQueue.main.async(execute: {
                self.btnStart.setTitle("Start Virtual iBeacon", for: UIControlState())
            })
        }
        
    }
    
    func initBeacon() {
        let localBeaconUUID = "29B74DA3-3F85-4644-9E96-9D5A3FDEB410"
        let localBeaconMajor: CLBeaconMajorValue = 1529
        let localBeaconMinor: CLBeaconMinorValue = 5830
        
        let uuid = UUID(uuidString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "blucomm")
        
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state == .poweredOn {
            print("State: poweredOn")
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
        } else if peripheral.state == .poweredOff {
            print("State: poweredOff")
            peripheralManager.stopAdvertising()
        }
        
    }
    

}
