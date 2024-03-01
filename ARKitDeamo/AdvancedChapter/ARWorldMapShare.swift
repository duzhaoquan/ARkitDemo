//
//  ARWorldMapShare.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/2/22.
//

import SwiftUI
import RealityKit
import ARKit
import Combine
import MultipeerConnectivity

struct ARWorldMapShare: View {
    var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        ARWorldMapShareContainer(viewModel: viewModel)
            .onDisappear(perform: {
                viewModel.arView?.session.pause()
                viewModel.arView = nil
                viewModel.multipeerSession?.endConnect()
                viewModel.multipeerSession = nil
                print("ARWorldMapShare onDisappear")
            })
            .overlay(
                VStack{
                    Spacer()
                    
                    Button(action: {viewModel.saveWorldMap()}) {
                        Text("发送AR环境信息")
                            .frame(width:250,height:50)
                            .font(.system(size: 17))
                            .foregroundColor(.black)
                            .background(Color.white)
                        
                            .opacity(0.6)
                    }
                    .cornerRadius(10)
                    Spacer().frame(height: 40)
                }
            ).edgesIgnoringSafeArea(.all).navigationTitle("共享ARWorldMap")
    }
  

    
    
    
    
    class ViewModel: NSObject,ARSessionDelegate{
        var arView: ARView? = nil
        var multipeerSession: MultipeerSession? = nil
        
      
        var planeEntity : ModelEntity? = nil
        var raycastResult : ARRaycastResult?
        var isPlaced = false
        var robotAnchor: AnchorEntity?
        let robotAnchorName = "drummerRobot"
        
        
        func createPlane()  {
            if multipeerSession == nil {
                multipeerSession = MultipeerSession(serviceType: "ar-sharing", receivedDataHandler: reciveData(_:from:), peerJoinedHandler: peerJoined(_:), peerLeftHandler: peerLeft(_:), peerDiscoveredHandler: peerDiscovery(_:))
            }
            guard let arView = arView else {
                return
            }
          
            if let an = arView.scene.anchors.first(where: { an in
                an.name == "setModelPlane"
            }){
                arView.scene.anchors.remove(an)
            }
            
            let planeMesh = MeshResource.generatePlane(width: 0.15, depth: 0.15)
            var planeMaterial = SimpleMaterial(color:.white,isMetallic: false)
            planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
            let planeAnchor = AnchorEntity(plane: .horizontal)
            
            do {
                let planeMesh = MeshResource.generatePlane(width: 0.15, depth: 0.15)
                var planeMaterial = SimpleMaterial(color: SimpleMaterial.Color.red, isMetallic: false)
                planeMaterial.color =  try SimpleMaterial.BaseColor(tint:UIColor.yellow.withAlphaComponent(0.9999), texture: MaterialParameters.Texture(TextureResource.load(named: "AR_Placement_Indicator")))
                planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
                
                planeAnchor.addChild(planeEntity!)
                planeAnchor.name = "setModelPlane"
                
                arView.scene.addAnchor(planeAnchor)
            } catch let error {
                print("加载文件失败:\(error)")
            }
        }
        func saveWorldMap() {
            print("save:\(String(describing: arView))")
            
            self.arView?.session.getCurrentWorldMap(completionHandler: {[weak self] loadWorld, error in
                guard let worldMap = loadWorld else {
                    print("当前无法获取ARWorldMap:\(error!.localizedDescription)")
                    return
                }
               
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
                    self?.multipeerSession?.sendToAllPeers(data, reliably: true)
                    print("ARWorldMap已发送")
                } catch {
                    fatalError("无法序列化ARWorldMap: \(error.localizedDescription)")
                }
            })
        }
        
        func reciveData(_ data: Data,from peer: MCPeerID) {
            
            var worldMap: ARWorldMap?
            do {
                worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
            } catch let error {
                print("ARWorldMap文件格式不正确:\(error)")
            }
            guard let worldMap = worldMap else {
                print("无法解压ARWorldMap")
                return
            }
            print("收到ARWorldMap")
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = .horizontal
            config.initialWorldMap = worldMap
            
            self.arView?.session.run(config,options: [.resetTracking, .removeExistingAnchors])
                 
        }
        
        func peerDiscovery(_ peer: MCPeerID) -> Bool{
            guard let multipeerSession = multipeerSession else {
                return false
            }
            if multipeerSession.connectedPeers.count > 3{
                return false
            }
            return true
        }
        func peerJoined(_ peer: MCPeerID) {
        }
        func peerLeft(_ peer: MCPeerID) {
        }
        
        func setupGesture(){
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            self.arView?.addGestureRecognizer(tap)
        }
        @objc func handleTap(sender: UITapGestureRecognizer){
            guard let raycastResult = raycastResult else {
                return
            }
            sender.isEnabled = false
            sender.removeTarget(nil, action: nil)
            isPlaced = true
            let anchor = ARAnchor(name: robotAnchorName, transform: raycastResult.worldTransform )
            self.arView?.session.add(anchor: anchor)
            
            robotAnchor = AnchorEntity(anchor: anchor)
            
            
            do {
                let robot =  try ModelEntity.load(named: "toy_drummer")
                robotAnchor?.addChild(robot)
                robot.scale = [0.01,0.01,0.01]
                self.arView?.scene.addAnchor(robotAnchor!)
                print("Total animation count : \(robot.availableAnimations.count)")
                robot.playAnimation(robot.availableAnimations[0].repeat())
            } catch {
                print("找不到USDZ文件")
            }
            
           
            planeEntity?.removeFromParent()
            planeEntity = nil
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard !isPlaced, let arView = arView else{
                return
            }
            //射线检测
            guard let result = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal).first else {
                return
            }
            raycastResult = result
            planeEntity?.setTransformMatrix(result.worldTransform, relativeTo: nil)
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard !anchors.isEmpty,robotAnchor == nil else {
               
                return
            }
            var panchor: ARAnchor? = nil
            for anchor in anchors {
                if anchor.name == robotAnchorName {
                    panchor = anchor
                    break
                }
            }
            guard let pAnchor = panchor else {
                return
            }
            //放置虚拟元素
            robotAnchor = AnchorEntity(anchor: pAnchor)
            do {
                let robot =  try ModelEntity.load(named: "toy_drummer")
                robotAnchor?.addChild(robot)
                robot.scale = [0.01,0.01,0.01]
                self.arView?.scene.addAnchor(robotAnchor!)
                print("Total animation count : \(robot.availableAnimations.count)")
                robot.playAnimation(robot.availableAnimations[0].repeat())
            } catch {
                print("找不到USDZ文件")
            }
            isPlaced = true
            planeEntity?.removeFromParent()
            planeEntity = nil
            print("加载模型成功")
        }
        
    }
}
struct ARWorldMapShareContainer: UIViewRepresentable {
    var viewModel: ARWorldMapShare.ViewModel
    func makeUIView(context: Context) -> some ARView {
        let arView = ARView(frame: .zero)
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        uiView.session.run(config)
        uiView.session.delegate = viewModel
        viewModel.arView = uiView
        viewModel.createPlane()
        viewModel.setupGesture()
    }
    
}
#Preview {
    ARWorldMapShare()
}
