//
//  ARWorldMapSaveAndLoad.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/2/20.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

struct ARWorldMapSaveAndLoad: View {
    var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        ARWorldMapSaveAndLoadContainer(viewModel: viewModel)
            .overlay(
                VStack{
                    Spacer()
                    
                    HStack{
                        Button(action: {loadWorldMap()}) {
                            Text("加载AR信息")
                                .frame(width:150,height:50)
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                                .background(Color.white)
                            
                                .opacity(0.6)
                        }
                        .cornerRadius(10)
                        
                        Button(action: {saveWorldMap()}) {
                            Text("保存AR信息")
                                .frame(width:150,height:50)
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                                .background(Color.white)
                            
                                .opacity(0.6)
                        }
                        .cornerRadius(10)
                    }
                    Spacer().frame(height: 40)
                }
            ).edgesIgnoringSafeArea(.all).navigationTitle("保存与加载ARWorldMap")
    }
    var mapSaveURL: URL = {
        do {
            return try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("arworldmap.arexperience")
        } catch {
            fatalError("获取路径出错: \(error.localizedDescription)")
        }
    }()

    func saveWorldMap() {
        print("save:\(String(describing: viewModel.arView))")
        
        self.viewModel.arView?.session.getCurrentWorldMap(completionHandler: { loadWorld, error in
            guard let worldMap = loadWorld else {
                print("当前无法获取ARWorldMap:\(error!.localizedDescription)")
                return
            }
           
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
                try data.write(to: mapSaveURL, options: [.atomic])
                print("ARWorldMap保存成功")
            } catch {
                fatalError("无法保存ARWorldMap: \(error.localizedDescription)")
            }
        })
    }
    func loadWorldMap() {
        print("load:\(String(describing: viewModel.arView))")
        guard let data = try? Data(contentsOf: mapSaveURL) else {
            print("load world map faile")
            return
        }
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
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        config.initialWorldMap = worldMap
        
        self.viewModel.arView?.session.run(config,options: [.resetTracking, .removeExistingAnchors])
             
    }
    
    class ViewModel: NSObject,ARSessionDelegate{
        var arView: ARView? = nil
        
      
        var planeEntity : ModelEntity? = nil
        var raycastResult : ARRaycastResult?
        var isPlaced = false
        var robotAnchor: AnchorEntity?
        let robotAnchorName = "drummerRobot"
        var planeAnchor = AnchorEntity()
        
        func createPlane()  {
            
            guard let arView = arView else {
                return
            }
            
            if let an = arView.scene.anchors.first(where: { an in
                an.name == "setModelPlane"
            }){
                arView.scene.anchors.remove(an)
            }
            do {
                let planeMesh = MeshResource.generatePlane(width: 0.15, depth: 0.15)
                var planeMaterial = SimpleMaterial(color: SimpleMaterial.Color.red, isMetallic: false)
                planeMaterial.color =  try SimpleMaterial.BaseColor(tint:UIColor.yellow.withAlphaComponent(0.9999), texture: MaterialParameters.Texture(TextureResource.load(named: "AR_Placement_Indicator")))
                planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])
                
                planeAnchor = AnchorEntity(plane: .horizontal)
                planeAnchor.addChild(planeEntity!)
                planeAnchor.name = "setModelPlane"
                
                arView.scene.addAnchor(planeAnchor)
            } catch let error {
                print("加载文件失败:\(error)")
            }
        }
        
        func setupGesture(){
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            self.arView?.addGestureRecognizer(tap)
        }
        @objc func handleTap(sender: UITapGestureRecognizer){
            sender.isEnabled = false
            sender.removeTarget(nil, action: nil)
            isPlaced = true
            let anchor = ARAnchor(name: robotAnchorName, transform: raycastResult?.worldTransform ?? simd_float4x4())
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
            
//            var cancellable: Cancellable?
//            cancellable = ModelEntity.loadModelAsync(named: "toy_drummer.usdz")
//                .sink(receiveCompletion: { error in
//                    print("laod error:\(error)")
//                    cancellable?.cancel()
//                }, receiveValue: {[weak self] model in
//                    guard let robotAnchor = self?.robotAnchor else {
//                        return
//                    }
//                    robotAnchor.addChild(model)
//                    model.scale = [0.01,0.01,0.01]
//                    self?.arView?.scene.addAnchor(robotAnchor)
//                    //用异步方法加载模型开启骨骼动画会crash，不知到是啥原因
//                    //model.playAnimation(model.availableAnimations[0].repeat())
//                    cancellable?.cancel()
//                })
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

struct ARWorldMapSaveAndLoadContainer: UIViewRepresentable {
    var viewModel: ARWorldMapSaveAndLoad.ViewModel
    
    func makeUIView(context: Context) -> some ARView {
        let arView = ARView(frame: .zero)
       
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        uiView.session.run(config)
        
        viewModel.arView = uiView
        uiView.session.delegate = viewModel
        
        viewModel.createPlane()
        viewModel.setupGesture()
        
    }
    
}
#Preview {
    ARWorldMapSaveAndLoad()
}
