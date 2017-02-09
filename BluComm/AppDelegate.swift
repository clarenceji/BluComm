//
//  AppDelegate.swift
//  BluComm
//
//  Created by Clarence Ji on 7/6/16.
//  Copyright © 2016 Clarence Ji. All rights reserved.
//

import UIKit
import CoreLocation
import MultipeerConnectivity
import CoreBluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let userDefaults = UserDefaults.standard
    var locationManager: CLLocationManager?

    // Variables storing Multipeer Connectivity managers
    var backgroundTask: UIBackgroundTaskIdentifier!
    var blucommMCAdvertiser: MCNearbyServiceAdvertiser?
    var blucommMCBrowser: MCNearbyServiceBrowser?
    var blucommMCSession: MCSession?
    
    var serviceStarted = false
    var mcController: MCTestViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        startMonitoringBeacons()
        
        // Setup Local Notification
        let notificationCategory:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        notificationCategory.identifier = "blucomm.notifications.general"
        
        // registerting for the notification.
        application.registerUserNotificationSettings(UIUserNotificationSettings(types:[.sound, .alert, .badge], categories: nil))
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        self.terminateMultipeer(application)
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("AppDelegate: Resume Multipeer Connectivity now.")
        if mcController?.btnStart.titleLabel?.text == "Stop" {
            self.blucommMCAdvertiser?.startAdvertisingPeer()
            self.blucommMCBrowser?.startBrowsingForPeers()
            
            self.serviceStarted = true
        }
        self.backgroundTask = UIBackgroundTaskInvalid
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("terminate")
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        
        // If app is not in background, present an alert view stating there's iBeacon found.
        if notification.category == "blucomm.ibeacon" {
            let currentVC = self.window!.rootViewController! as UIViewController
            
            let alertView = UIAlertController(title: "iBeacon found!", message: nil, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            currentVC.present(alertView, animated: true, completion: nil)
        }
        
    }

}


// MARK: - Monitor Nearby iBeacons
extension AppDelegate {
    
    /// Start monitoring nearby beacons with fixed beacon ID
    fileprivate func startMonitoringBeacons() {
        
        // Setup properties of iBeacons to be monitored
        let uuidString = "29B74DA3-3F85-4644-9E96-9D5A3FDEB410"
        let beaconIdentifier = "blucomm"
        let beaconUUID = UUID(uuidString: uuidString)
        let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID!,
                                                         identifier: beaconIdentifier)
        
        // Setup location manager and request user permission
        locationManager = CLLocationManager()
        if(locationManager!.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization))) {
            locationManager!.requestAlwaysAuthorization()
        }
        locationManager!.delegate = self
        
        // Prevent beacon updates from being paused so beacons can still be ranged when not in app
        locationManager!.pausesLocationUpdatesAutomatically = false
        if #available(iOS 9.0, *) {
            locationManager!.allowsBackgroundLocationUpdates = true
        } else {
            // TODO: Fallback on earlier versions
        }
        
        // Start monitoring
        locationManager!.startMonitoring(for: beaconRegion)
        locationManager!.startRangingBeacons(in: beaconRegion)
        
    }
    
}

// MARK: - Multipeer Connectivity Related
extension AppDelegate {
    
    /// Terminate Multipeer Connectivity **when the app is killed by system** (when in background).
    ///
    /// - Parameter application: This should be passed from ```applicationDidEnterBackground(_:)``` method
    fileprivate func terminateMultipeer(_ application: UIApplication) {
        
        self.backgroundTask = application.beginBackgroundTask(expirationHandler: {
            
            print("AppDelegate: Stop Multipeer Connectivity now.")
            // Send termination message to peers
            self.mcController?.sendMessageToPeers(text: "has left the chat")
            // Disconnect from current session
            self.blucommMCSession?.disconnect()
            // Stop advertising and browsing peers
            self.blucommMCAdvertiser?.stopAdvertisingPeer()
            self.blucommMCBrowser?.stopBrowsingForPeers()
            
            self.serviceStarted = false
            
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
            
        })
        
    }
    
}

extension AppDelegate: CLLocationManagerDelegate {
    
    /// Send a local notification to user
    ///
    /// - Parameter message: Message to be presented in the notification
    fileprivate func sendLocalNotificationWithMessage(message: String!) {
        
        let notification:UILocalNotification = UILocalNotification()
        notification.category = "blucomm.ibeacon"
        notification.alertBody = message
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
        
    }
    
    internal func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        // If there is beacon nearby, send local notification to user every 60 seconds.
        if beacons.count > 0 {
            
            let currentTime = Int(NSDate().timeIntervalSince1970)
            
            // Get the saved time when last time a (multiple) beacon(s) is/are ranged
            let savedTime = userDefaults.integer(forKey: "blucomm.savedtime")
            
            // If the difference between times is greater than 1 minute, then send local notification
            if (currentTime - savedTime) > 60 {
                
                // Send local notification
                sendLocalNotificationWithMessage(message: "BluComm user nearby, open the app for details.")
                // Save the current time for next iteration
                userDefaults.set(currentTime, forKey: "blucomm.savedtime")
                
            }
            
        }
        
    }
    
    
}

// MARK: - Core Bluetooth Central Manager Delegate
extension AppDelegate: CBCentralManagerDelegate {
    
    @available(iOS 5.0, *)
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    
}

