//
//  ViewController.swift
//  BluComm
//
//  Created by Clarence Ji on 7/7/16.
//  Copyright © 2016 Clarence Ji. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MCTestViewController: UIViewController, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate, UITextFieldDelegate {

    @IBOutlet var txtFieldName: UITextField!
    @IBOutlet var txtFieldMsg: UITextField!
    @IBOutlet var btnStart: UIButton!
    @IBOutlet var txtViewLog: UITextView!
    @IBOutlet var labelConnCount: UILabel!
    
    private let kServiceType = "blucomm"
    private var serviceStarted = false
    private let myPeerID: MCPeerID = MCPeerID(displayName: UIDevice.current().name)
    var advertiser: MCNearbyServiceAdvertiser!
    var browser: MCNearbyServiceBrowser!
    
    lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.txtFieldMsg.delegate = self
        self.txtFieldName.delegate = self
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: kServiceType)
        
        self.browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: kServiceType)
        
        self.advertiser.delegate = self
//        self.advertiser.startAdvertisingPeer()
        
        self.browser.delegate = self
//        self.browser.startBrowsingForPeers()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    // MARK: - Advertiser

//    func initAdvertiser() {
//        
//        self.myPeerID = MCPeerID(displayName: self.txtFieldName.text == "" ? "Anonymous" : self.txtFieldName.text!)
//        
//        self.session = MCSession(peer: myPeerID!, securityIdentity: nil, encryptionPreference: .required)
//        session?.delegate = self
//        
//        self.advertiser = MCNearbyServiceAdvertiser(peer: self.myPeerID!, discoveryInfo: nil, serviceType: kServiceType)
//        self.advertiser?.delegate = self
//        self.advertiser?.startAdvertisingPeer()
//        
//        addTextToLog(text: "✅ Advertiser initiated")
//        
//    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: (Bool, MCSession?) -> Void) {
        
        addTextToLog(text: "💌 Invitation Received from Peer: \(peerID.displayName)")
//        let alertView = UIAlertController(title: "Inivation Received!", message: "Peer name: \(peerID.displayName)", preferredStyle: .alert)
//        alertView.addAction(UIAlertAction(title: "Accept", style: .default, handler: { (aa) in
//            invitationHandler(true, self.session)
//        }))
//        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        self.present(alertView, animated: true, completion: nil)
        
        invitationHandler(true, self.session)
        
        let string = "Hello"
        let data = string.data(using: .utf8)!
        do {
            try session.send(data, toPeers: [peerID], with: .reliable)
        } catch {
            addTextToLog(text: "\(error)")
        }
        
    }
    
    func terminateAdvertiser() {
        self.advertiser?.stopAdvertisingPeer()
        addTextToLog(text: "❌ Advertiser terminated")
    }
    
    // MARK: - Browser
    
//    func initBrowser() {
//        
//        self.browser = MCNearbyServiceBrowser(peer: self.myPeerID!, serviceType: kServiceType)
//        browser?.delegate = self
//        
//        addTextToLog(text: "✅ Browser initiated")
//        
//    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        addTextToLog(text: "💯 Found Peer: \(peerID.displayName)")
        
//        let alertView = UIAlertController(title: "Found Peer!", message: "Peer name: \(peerID.displayName)", preferredStyle: .alert)
//        alertView.addAction(UIAlertAction(title: "Invite", style: .default, handler: { (aa) in
//            browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
//        }))
//        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        self.present(alertView, animated: true, completion: nil)
        
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 10)
        
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
        addTextToLog(text: "☢️ Lost Peer: \(peerID.displayName)")
        
    }
    
    func terminateBrowser() {
        self.browser?.stopBrowsingForPeers()
        addTextToLog(text: "❌ Browser terminated")
    }
    
    // MARK: - Button Actions
    
    @IBAction func btnStartTapped(_ sender: AnyObject) {
        
        if !serviceStarted {
            serviceStarted = true
//            self.initAdvertiser()
//            self.initBrowser()
            advertiser.startAdvertisingPeer()
            browser.startBrowsingForPeers()
            DispatchQueue.main.async(execute: {
                self.btnStart.setTitle("Stop", for: UIControlState())
            })
        } else {
            serviceStarted = false
//            self.terminateBrowser()
//            self.terminateAdvertiser()
            advertiser.stopAdvertisingPeer()
            browser.stopBrowsingForPeers()
            
            DispatchQueue.main.async(execute: {
                self.btnStart.setTitle("Start", for: UIControlState())
            })
        }
        
    }
    
    @IBAction func btnSendTapped(_ sender: AnyObject) {
        
    }
    
    @IBAction func btnRefreshTapped(_ sender: AnyObject) {
        let count = self.session.connectedPeers.count
        DispatchQueue.main.async { 
            self.labelConnCount.text = "Connected: \(count)"
        }
        addTextToLog(text: String(session.connectedPeers))
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
        addTextToLog(text: "Peer status changed: \(state.rawValue)")
    }
    
    
    // Received data from remote peer.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let string = String(data: data, encoding: .utf8)
        print("Did receive data: \(string!)")
        addTextToLog(text: string!)
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
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: NSError?) {
        
    }


}
