//
//  CooperationSession.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/2/27.
//

import SwiftUI
import ARKit
import RealityKit
import MultipeerConnectivity

struct CooperationSession: View {
    static var arView:ARView?
    static var multipeerSession: MultipeerSession?
    var body: some View {
        CooperationSessionContent()
            .onDisappear(perform: {
                CooperationSession.arView?.session.delegate = nil
                CooperationSession.arView?.session.pause()
                CooperationSession.arView = nil
                CooperationSession.multipeerSession?.endConnect()
                CooperationSession.multipeerSession = nil
                print("CooperationSession onDisappear")
            })
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("协作Session")
    }
}


struct CooperationSessionContent:UIViewRepresentable {
    
    func makeUIView(context: Context) -> some ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.isCollaborationEnabled = true
        config.planeDetection = .horizontal
        
        arView.session.run(config,options: [.resetTracking,.removeExistingAnchors])
        arView.session.delegate = context.coordinator
         
        CooperationSession.arView = arView
        
        context.coordinator.createPlane()
        context.coordinator.addGesture()
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var multipeerSession: MultipeerSession?{
            return CooperationSession.multipeerSession
        }
        var planeEntity : ModelEntity? = nil
        var raycastResult : ARRaycastResult?
        var arView: ARView? {
            return CooperationSession.arView
        }
        
        func createPlane(){
            CooperationSession.multipeerSession = MultipeerSession(serviceType: "cooper-session", receivedDataHandler: receiveData(data:from:), peerJoinedHandler: peerJoined(_:), peerLeftHandler: peerLeft(_:), peerDiscoveredHandler: peerDiscovered(_:))
            let planeMesh = MeshResource.generatePlane(width: 0.15, depth: 0.15)
            let planeMaterial = SimpleMaterial(color:.white,isMetallic: false)
            planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
            let planeAnchor = AnchorEntity(plane: .horizontal)
            
            do {
                let planeMesh = MeshResource.generatePlane(width: 0.15, depth: 0.15)
                var planeMaterial = SimpleMaterial(color: SimpleMaterial.Color.red, isMetallic: false)
                planeMaterial.color =  try SimpleMaterial.BaseColor(tint:UIColor.yellow.withAlphaComponent(0.9999), texture: MaterialParameters.Texture(TextureResource.load(named: "AR_Placement_Indicator")))
                planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
                
                planeAnchor.addChild(planeEntity!)
                
                arView?.scene.addAnchor(planeAnchor)
            } catch let error {
                print("加载文件失败:\(error)")
            }
        }
        func addGesture(){
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            arView?.addGestureRecognizer(tap)
        }
        @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
            guard let raycastResult = raycastResult else {
                print("还未检测到平面")
                return
            }
            let anchor = ARAnchor(name: "objectAnchor", transform: raycastResult.worldTransform)
            arView?.session.add(anchor: anchor)
        }
        
        //ARSessionDelegate
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard let arView = arView,  let result = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal).first else{
                return
            }
            raycastResult = result
            planeEntity?.setTransformMatrix(result.worldTransform, relativeTo: nil)
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let arView = arView else {
                return
            }
            for anchor in anchors {
                if anchor.name == "objectAnchor"{
                   
                    let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.1), materials: [SimpleMaterial.init(color: .green, isMetallic: false)])
                    box.position = [0,0.05,0]
                    let anchorEntity = AnchorEntity(anchor: anchor)
                    anchorEntity.addChild(box)
                    arView.scene.addAnchor(anchorEntity)
                }
            }
        }
        
        func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
            guard let multipeerSession = multipeerSession else {
                return
            }
            
            if !multipeerSession.connectedPeers.isEmpty {
                
                do {
                    let encodeData = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
                    
                    multipeerSession.sendToAllPeers(encodeData, reliably: data.priority == .critical)
                } catch  {
                    print("encode data faile")
                }
            }
        }
        
        func receiveData(data:Data,from peer: MCPeerID){
            
           
            if let data = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data){
                
                if data.priority == .critical {
                    arView?.session.update(with: data)
                    print(" data updated")
                }
                
            }
            
        }
        
        
        func peerDiscovered(_ peer: MCPeerID) -> Bool {
            guard let multipeerSession = multipeerSession else {
                return false
            }
            
            if multipeerSession.connectedPeers.count > 3 {
                return false
            }else{
                return true
            }
            
        }
        
        func peerJoined(_ peer: MCPeerID) {
        }
        func peerLeft(_ peer: MCPeerID) {
        }
        
        
    }
}

#Preview {
    CooperationSession()
}
