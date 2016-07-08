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

class BeaconRViewController: UIViewController, CBCentralManagerDelegate {

    @IBOutlet var txtViewLog: UITextView!
    
//    var locationManager: CLLocationManager!
    var centralManager: CBCentralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.requestAlwaysAuthorization()
        
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [
            CBCentralManagerOptionRestoreIdentifierKey: "com.cjlondon.blucomm.cbcentralmanager"
            ])
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        
    }
    
//    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        if status == .authorizedAlways {
//            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
//                if CLLocationManager.isRangingAvailable() {
//                    startScanning()
//                }
//            }
//        }
//    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "29B74DA3-3F85-4644-9E96-9D5A3FDEB410")!
//        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "blucomm")
        
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
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : AnyObject], rssi RSSI: NSNumber) {
        addTextToLog(text: "Discovered, RSSI: \(RSSI.intValue)")
    }
    
//    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
//        print("Did Range Beacons")
//        if beacons.count > 0 {
//            let beacon = beacons[0] 
//            addTextToLog(text: beacon.proximity.stringValue())
//        } else {
//            addTextToLog(text: "unknown")
//        }
//    }

    private func addTextToLog(text: String) {
        
        print(text)
        DispatchQueue.main.async {
            let newString = text + "\n===================\n" + self.txtViewLog.text
            self.txtViewLog.text = newString
        }
        
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
