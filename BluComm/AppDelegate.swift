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
class AppDelegate: UIResponder, UIApplicationDelegate, CBCentralManagerDelegate {
    
    var window: UIWindow?
    
    let userDefaults = UserDefaults.standard
    var locationManager: CLLocationManager?

    var backgroundTask: UIBackgroundTaskIdentifier!
    var blucommMCAdvertiser: MCNearbyServiceAdvertiser?
    var blucommMCBrowser: MCNearbyServiceBrowser?
    var blucommMCSession: MCSession?
    
    var serviceStarted = false
    var mcController: MCTestViewController?

    private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        setUpiBeacon()
        
        let notificationCategory:UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
        notificationCategory.identifier = "blucomm.notifications.general"
        
        // registerting for the notification.
        application.registerUserNotificationSettings(UIUserNotificationSettings(types:[.sound, .alert, .badge], categories: nil))
        
        return true
    }
    
    private func setUpiBeacon() {
        let uuidString = "29B74DA3-3F85-4644-9E96-9D5A3FDEB410"
        let beaconIdentifier = "blucomm"
        let beaconUUID = UUID(uuidString: uuidString)
        let beaconRegion:CLBeaconRegion = CLBeaconRegion(proximityUUID: beaconUUID!,
                                                         identifier: beaconIdentifier)
        
        locationManager = CLLocationManager()
        if(locationManager!.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization))) {
            locationManager!.requestAlwaysAuthorization()
        }
        locationManager!.delegate = self
        locationManager!.pausesLocationUpdatesAutomatically = false
        
        if #available(iOS 9.0, *) {
            locationManager!.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }

        locationManager!.startMonitoring(for: beaconRegion)
        locationManager!.startRangingBeacons(in: beaconRegion)
        // locationManager!.startUpdatingLocation()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.backgroundTask = application.beginBackgroundTask(expirationHandler: { 
            
            // Terminate Multipeer Connectivity
            print("AppDelegate: Stop Multipeer Connectivity now.")
            self.mcController?.sendMessageToPeers(text: "has left the chat")
            self.blucommMCSession?.disconnect()
            self.blucommMCAdvertiser?.stopAdvertisingPeer()
            self.blucommMCBrowser?.stopBrowsingForPeers()
            
            self.serviceStarted = false
            
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
            
        })
        
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
        
        if notification.category == "blucomm.ibeacon" {
            let currentVC = self.window!.rootViewController! as UIViewController
            
            let alertView = UIAlertController(title: "iBeacon found!", message: nil, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            currentVC.present(alertView, animated: true, completion: nil)
        }
        
    }
    
    /*!
     *  @method centralManagerDidUpdateState:
     *
     *  @param central  The central manager whose state has changed.
     *
     *  @discussion     Invoked whenever the central manager's state has been updated. Commands should only be issued when the state is
     *                  <code>CBCentralManagerStatePoweredOn</code>. A state below <code>CBCentralManagerStatePoweredOn</code>
     *                  implies that scanning has stopped and any connected peripherals have been disconnected. If the state moves below
     *                  <code>CBCentralManagerStatePoweredOff</code>, all <code>CBPeripheral</code> objects obtained from this central
     *                  manager become invalid and must be retrieved or discovered again.
     *
     *  @see            state
     *
     */
    @available(iOS 5.0, *)
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }


}

