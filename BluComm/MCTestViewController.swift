//
//  ViewController.swift
//  BluComm
//
//  Created by Clarence Ji on 7/7/16.
//  Copyright © 2016 Clarence Ji. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MCTestViewController: UIViewController, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, UITextFieldDelegate {

    @IBOutlet var txtFieldName: UITextField!
    @IBOutlet var txtFieldMsg: UITextField!
    @IBOutlet var btnStart: UIButton!
    @IBOutlet var btnSend: UIButton!
    @IBOutlet var txtViewLog: UITextView!
    @IBOutlet var labelConnCount: UILabel!
    
    private var isAppInBackground = false
    
    private let kServiceType = "blucomm"
    var serviceStarted = (UIApplication.shared.delegate as! AppDelegate).serviceStarted
    private let myPeerID: MCPeerID = MCPeerID(displayName: UIDevice.current.name)
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        session.delegate = self
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // App Goes to Background Notification
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: .UIApplicationWillResignActive, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: .UIApplicationWillEnterForeground, object: nil)

        // Do any additional setup after loading the view.
        self.txtFieldMsg.delegate = self
        self.txtFieldName.delegate = self
        
        self.txtFieldMsg.addTarget(self, action: #selector(MCTestViewController.textFieldDidChange(_:)), for: .editingChanged)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.mcController = self
        if appDelegate.blucommMCAdvertiser == nil {
            
            self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: kServiceType)
            self.browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: kServiceType)
            self.advertiser.delegate = self
            self.browser.delegate = self
            
            appDelegate.blucommMCAdvertiser = advertiser
            appDelegate.blucommMCBrowser = browser
            appDelegate.blucommMCSession = session
            
        } else {
            
            self.advertiser = appDelegate.blucommMCAdvertiser
            self.browser = appDelegate.blucommMCBrowser
            if let storedSession = appDelegate.blucommMCSession {
                self.session = storedSession
            }
            
        }
        
        
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        DispatchQueue.main.async(execute: {
            self.btnSend.isEnabled = textField.text != "" ? true : false
        })
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func appMovedToBackground() {
        self.isAppInBackground = true
    }
    
    func appMovedToForeground() {
        self.isAppInBackground = false
    }
    
    // MARK: - Advertiser
    @available(iOS 7.0, *)
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
        addTextToLog(text: "💌 Invitation Received from Peer: \(peerID.displayName)")
        
        invitationHandler(true, self.session)
        
    }
    
    // MARK: - Browser
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        addTextToLog(text: "💯 Found Peer: \(peerID.displayName)")
        self.btnRefreshTapped(self)
 
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
        addTextToLog(text: "☢️ Lost Peer: \(peerID.displayName)")
        self.btnRefreshTapped(self)
        
    }
    
    // MARK: - Button Actions
    
    @IBAction func btnStartTapped(_ sender: AnyObject) {
        
        if !serviceStarted {
            serviceStarted = true
            advertiser.startAdvertisingPeer()
            browser.startBrowsingForPeers()
            DispatchQueue.main.async(execute: {
                self.btnStart.setTitle("Stop", for: UIControlState())
            })
        } else {
            serviceStarted = false
            self.sendMessageToPeers(text: "has left the chat.")
            session.disconnect()
            advertiser.stopAdvertisingPeer()
            browser.stopBrowsingForPeers()
            
            DispatchQueue.main.async(execute: {
                self.btnStart.setTitle("Start", for: UIControlState())
            })
        }
        
    }
    
    func sendMessageToPeers(text: String) {
        
        let string = text
        let data = string.data(using: .utf8)!
        
        do {
            try session.send(data, toPeers: self.session.connectedPeers, with: .reliable)
            addTextToLog(text: "Me: \(string)")
            
            DispatchQueue.main.async(execute: {
                self.txtFieldMsg.text = ""
                self.btnSend.isEnabled = false
            })
            
        } catch {
            print(error)
            addTextToLog(text: "\(error)")
        }
        
    }
    
    @IBAction func btnSendTapped(_ sender: AnyObject) {
        
        if txtFieldMsg.text != "" {
            self.sendMessageToPeers(text: txtFieldMsg.text!)
        }
        
    }
    
    @IBAction func btnRefreshTapped(_ sender: AnyObject) {
        let count = self.session.connectedPeers.count
        DispatchQueue.main.async { 
            self.labelConnCount.text = "Connected: \(count)"
        }
        addTextToLog(text: String(describing: session.connectedPeers))
    }
    
    private func addTextToLog(text: String) {
        
        print(text)
        DispatchQueue.main.async {
            let newString = text + "\n===================\n" + self.txtViewLog.text
            self.txtViewLog.text = newString
        }
        
    }
    
    
    // MARK: - Session Delegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        addTextToLog(text: "Peer \(peerID.displayName) status changed: \(state.rawValue)")
        self.btnRefreshTapped(self)
        if state.rawValue == 2 {
            // Connected
            addTextToLog(text: "\(peerID.displayName) says hello!")
        }
    }
    
    
    // Received data from remote peer.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        let string = String(data: data, encoding: .utf8)
        print("Did receive data: \(string!)")
        addTextToLog(text: peerID.displayName + ": " + string!)
        
        if self.isAppInBackground {
            
            print("blucomm.multipeerconn notification")
            let notification = UILocalNotification()
            notification.category = "blucomm.multipeerconn"
            notification.alertBody = peerID.displayName + ": " + string!
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.shared.scheduleLocalNotification(notification)
            
        }
        
    }
    
    
    // Received a byte stream from remote peer.
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    
    // Start receiving a resource from remote peer.
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }


}
