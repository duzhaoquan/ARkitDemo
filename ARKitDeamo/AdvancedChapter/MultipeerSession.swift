//
//  MultipeerSession.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/2/22.
//

import Foundation
import MultipeerConnectivity


class MultipeerSession: NSObject {
    
    static let serviceType = "ar-sharing"
    
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    private var session: MCSession!
    private var serviceBrowser: MCNearbyServiceBrowser!
    private var serviceAdvertiser: MCNearbyServiceAdvertiser!
    
    
    private let receivedDataHandler: (Data, MCPeerID) -> Void
    private let peerJoinedHandler: (MCPeerID) -> Void
    private let peerLeftHandler: (MCPeerID) -> Void
    private let peerDiscoveredHandler: (MCPeerID) -> Bool
    
    init(receivedDataHandler: @escaping (Data, MCPeerID) -> Void, 
         peerJoinedHandler: @escaping (MCPeerID) -> Void,
         peerLeftHandler: @escaping (MCPeerID) -> Void,
         peerDiscoveredHandler: @escaping (MCPeerID) -> Bool) {
        self.receivedDataHandler = receivedDataHandler
        self.peerJoinedHandler = peerJoinedHandler
        self.peerLeftHandler = peerLeftHandler
        self.peerDiscoveredHandler = peerDiscoveredHandler
        
        super.init()
        
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        
        serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: MultipeerSession.serviceType)
        serviceBrowser.delegate = self
        //搜索可用的服务
        serviceBrowser.startBrowsingForPeers()
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: MultipeerSession.serviceType)
        serviceAdvertiser.delegate = self
        //广播自己
        serviceAdvertiser.startAdvertisingPeer()
        
        
        
        
    }
    
    func sendToAllPeers(_ data: Data,reliably: Bool) {
        sendPeers(data, reliably: reliably, peers: connectedPeers)
    }
    func sendPeers(_ data: Data, reliably:Bool, peers: [MCPeerID]) {
        guard !peers.isEmpty else {
            return
        }
        do {
            try session.send(data, toPeers: peers, with: reliably ? .reliable : .unreliable )
        } catch let error {
            print(print("error sending data to peers \(peers): \(error.localizedDescription)"))
        }
    }
    
    var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }
}

extension MultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            peerJoinedHandler(peerID)
            print("链接成功peerID：\(peerID)")
        } else if state == .notConnected {
            print("断开链接peerID：\(peerID)")
            peerLeftHandler(peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        receivedDataHandler(data,peerID)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    
}
extension MultipeerSession: MCNearbyServiceBrowserDelegate{
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if peerDiscoveredHandler(peerID) {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
        }
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    
    
}
extension MultipeerSession: MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, session)
    }
    
    
}
