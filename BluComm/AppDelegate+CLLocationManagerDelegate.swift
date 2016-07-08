//
//  AppDelegate+CLLocationManagerDelegate.swift
//  BluComm
//
//  Created by Clarence Ji on 7/7/16.
//  Copyright © 2016 Clarence Ji. All rights reserved.
//

import UIKit
import CoreLocation

extension AppDelegate: CLLocationManagerDelegate {
        
    func sendLocalNotificationWithMessage(message: String!) {
        let notification:UILocalNotification = UILocalNotification()
        notification.category = "blucomm.ibeacon"
        notification.alertBody = message
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared().scheduleLocalNotification(notification)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
                
        if beacons.count > 0 {
            let currentTime = Int(NSDate().timeIntervalSince1970)
            let savedTime = userDefaults.integer(forKey: "blucomm.savedtime")
            if (currentTime - savedTime) > 60 {
                sendLocalNotificationWithMessage(message: "BluComm user nearby, open the app for details.")
                userDefaults.set(currentTime, forKey: "blucomm.savedtime")
            }
        }
    }
    
    
}
