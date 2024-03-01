//
//  SyncARSession.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/2/28.
//

import SwiftUI
import ARKit
import RealityKit
import MultipeerConnectivity
import Combine

struct SyncARSession: View {
    static var arView: ARView!
    static var multipeerSession: MultipeerSession?
    var body: some View {
        SnycARSessionContent()
            .onDisappear {
                SyncARSession.arView.session.delegate = nil
                SyncARSession.arView.session.pause()
                SyncARSession.arView = nil
                SyncARSession.multipeerSession?.endConnect()
                SyncARSession.multipeerSession = nil
                print("SyncARSession onDisappear")
            }
            .edgesIgnoringSafeArea(.all).navigationTitle("ARSession同步")
    }
   
}

struct SnycARSessionContent: UIViewRepresentable {

    func makeUIView(context: Context) -> some ARView {
        let arView = ARView(frame: .zero)
        
        
        arView.automaticallyConfigureSession = false
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
//        config.isCollaborationEnabled = true
        
        arView.session.run(config,options: [.resetTracking,.removeExistingAnchors])
        arView.session.delegate = context.coordinator
        
        SyncARSession.arView = arView
        context.coordinator.createPlane()
        context.coordinator.addGesture()
        
        
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject,ARSessionDelegate {
        
        deinit {
            subscribes.forEach {
                $0.cancel()
            }
            subscribes.removeAll()
            print("SnycARSessionContent--Coordinator deinit")
        }
        
        var number = 1
        var subscribes:[Cancellable] = []
        var arView: ARView? {
            return SyncARSession.arView
        }
        var multipeerSession: MultipeerSession? {
            return SyncARSession.multipeerSession
        }
        var planeEntity : ModelEntity? = nil
        var raycastResult : ARRaycastResult?
        
        
        func createPlane(){
            SyncARSession.multipeerSession = MultipeerSession(serviceType: "sync-session",receivedDataHandler: receiveData(data:from:), peerJoinedHandler: peerJoined(_:), peerLeftHandler: peerLeft(_:), peerDiscoveredHandler: peerDiscovered(_:))
             
            let planeMesh = MeshResource.generatePlane(width: 0.15, depth: 0.15)
            let planeMaterial = SimpleMaterial(color:.white,isMetallic: false)
            planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
            let planeAnchor = AnchorEntity(plane: .horizontal)
            planeAnchor.synchronization = nil
            do {
                let planeMesh = MeshResource.generatePlane(width: 0.15, depth: 0.15)
                var planeMaterial = SimpleMaterial(color: SimpleMaterial.Color.red, isMetallic: false)
                planeMaterial.color =  try SimpleMaterial.BaseColor(tint:UIColor.yellow.withAlphaComponent(0.9999), texture: MaterialParameters.Texture(TextureResource.load(named: "AR_Placement_Indicator")))
                planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
                
                planeAnchor.addChild(planeEntity!)
                arView?.scene.addAnchor(planeAnchor)
                
                arView?.scene.synchronizationService = multipeerSession?.syncService
            } catch let error {
                print("加载文件失败:\(error)")
            }
        }
        func randomColor() -> UIColor{
            return UIColor(red:CGFloat(arc4random()%256)/255.0,green:CGFloat(arc4random()%256)/255.0,blue: CGFloat(arc4random()%256)/255.0,alpha: 1.0 )
        }
        func addGesture(){
            guard let arView = arView else {
                return
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            arView.addGestureRecognizer(tap)
            
            
            //收到实体权限变更请求
            let subscribe = arView.scene.subscribe(to: SynchronizationEvents.OwnershipRequest.self, { event in
                if (Int(event.entity.name) ?? 0) % 2 == 0  {
                    //不允许变更权限
                    
                    print("------------不允许变更权限")
                    return
                }else{
                    //接受变更权限
                    print("------------允许变更权限")
                    event.accept()
                }
                
            })
            subscribes.append(subscribe)
            
            //监听添加的实体Entity
            let sub = arView.scene.subscribe(to: SceneEvents.DidAddEntity.self, {[weak self] event in
                self?.didAddEntitiy(entity: event.entity)
                
            })
            subscribes.append(sub)
        }
        @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
            guard let raycastResult = raycastResult else {
                print("还未检测到平面")
                return
            }
            
            let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.1), materials: [SimpleMaterial.init(color: randomColor(), isMetallic: false)])
            box.position = [0,0.05,0]
            let anchorEntity = AnchorEntity(raycastResult: raycastResult)
            
            anchorEntity.synchronization?.ownershipTransferMode = .manual
            box.synchronization?.ownershipTransferMode = .manual
            anchorEntity.name = "\(number)"
            box.generateCollisionShapes(recursive: false)
            
           
            anchorEntity.addChild(box)
            arView?.scene.addAnchor(anchorEntity)
        }
        
        func didAddEntitiy(entity: Entity) {
            if let entity = entity as? HasCollision {
                
                self.arView?.installGestures(.all, for: entity).forEach({ entityGestureRecognizer in
                    entityGestureRecognizer.addTarget(self, action: #selector(handleModelGesture))
                })
            }
        }
        
        @objc func handleModelGesture(_ sender: Any) {
            if let ges = sender as? EntityGestureRecognizer {
                //获取权限
                ges.entity?.runWithOwnership(completion: { res in
                    if case .success(_) = res {
                        
                       
                    }else {
                        print("--------获取所有者权限失败")
                    }
                })
            }
            
            
        }
        
        //ARSessionDelegate
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard let arView = arView, let result = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal).first else{
                return
            }
            raycastResult = result
            planeEntity?.setTransformMatrix(result.worldTransform, relativeTo: nil)
            
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
          
        
        }
        
        
        
        
        func receiveData(data:Data,from peer: MCPeerID){
            
            
        }
        
        
        func peerDiscovered(_ peer: MCPeerID) -> Bool {
//            guard let multipeerSession = multipeerSession else {
//                return false
//            }
//            
//            if multipeerSession.connectedPeers.count > 3 {
//                return false
//            }else{
//                return true
//            }
            return true
            
        }
        
        func peerJoined(_ peer: MCPeerID) {
        }
        func peerLeft(_ peer: MCPeerID) {
        }
        
        
    
    }
}

#Preview {
    SyncARSession()
}



public enum MHelperErrors: Error {
  case timedOut
  case failure
}

public extension HasSynchronization {
    
    func EntityManipulation() {
        if isOwner {
            //拥有某个实体的所有权，可以进行处理
            
            
        } else {
            requestOwnership { failure in
                if failure == .granted {
                    //没有某个实体的所有权，进行所有权申请，得到授权后可以进行处理
                }
            }
            
        }
    }
    
  /// Execute the escaping completion if you are the entity owner, once you receive ownership
  /// or call result failure if ownership cannot be granted to the caller.
  /// - Parameter completion: completion of type Result, success once ownership granted, failure if not granted
  func runWithOwnership(
    completion: @escaping (Result<HasSynchronization, Error>) -> Void
  ) {
    if self.isOwner {
      // If caller is already the owner
      completion(.success(self))
    } else {
      self.requestOwnership { (result) in
        if result == .granted {
          completion(.success(self))
        } else {
          completion(
            .failure(result == .timedOut ?
              MHelperErrors.timedOut :
              MHelperErrors.failure
            )
          )
        }
      }
    }
  }
    
    
}
