//
//  FaceChecking.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/24.
//

import SwiftUI
import ARKit
import RealityKit
import SceneKit

struct FaceChecking: View {
    @State var faceMetre = false
    @State var faceMask = false
    var body: some View {
        Group{
            if !faceMask {
                FaceCheckingContainer(faceMetre: $faceMetre)
            }else{
                FaceMaskContainer()
            }
        }
            .overlay(
                VStack{
                    Spacer()
                    if faceMask {
                        Text("左右滑动切换挂件")
                    }
                    HStack{
                        Button(action: {faceMetre.toggle()}) {
                            Text("切换面部显示")
                                .frame(width:150,height:50)
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                                .background(Color.white)
                            
                                .opacity(0.6)
                        }
                        .cornerRadius(10)
                        
                        Button(action: {faceMask.toggle()}) {
                            Text("显示挂件")
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
        )
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("人脸检测")
            .onDisappear {
                
            }
    }
}
struct FaceMaskContainer : UIViewRepresentable{
    
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        return arView
    }
    func updateUIView(_ uiView: ARView, context: Context) {
        guard ARFaceTrackingConfiguration.isSupported else {
            return
        }
       
        let config = ARFaceTrackingConfiguration()

        config.isWorldTrackingEnabled = false
        config.providesAudioData = false
        config.maximumNumberOfTrackedFaces =  1
        config.isLightEstimationEnabled = true
//        uiView.session = context.coordinator
        if let faceAnchor = try? FaceMask.loadGlass1() {
            uiView.scene.addAnchor(faceAnchor)
        }
        uiView.session.run(config,options: [.resetTracking, .removeExistingAnchors])
        context.coordinator.arView = uiView
        
        
        
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = [.left,.right]
        gesture.addTarget(context.coordinator, action: #selector(context.coordinator.changeGlass(gesture:)))
        uiView.addGestureRecognizer(gesture)
    }
    
    func makeCoordinator() -> FaceMaskContainerCoordinator {
        FaceMaskContainerCoordinator()
    }
    
    class FaceMaskContainerCoordinator: NSObject {
        var arView :ARView?
        var faceMaskCount = 0
        let numberOfMasks = 5
        @MainActor @objc func changeGlass(gesture: UISwipeGestureRecognizer){
            guard let arView = arView else {
                return
            }
            let jian = gesture.direction == .left
            jian ?  (faceMaskCount -= 1) : (faceMaskCount += 1)
            if faceMaskCount < 0 {
                faceMaskCount = 5
            }
            faceMaskCount %= numberOfMasks
            switch faceMaskCount {
            case 0:
                if let g = try? FaceMask.loadGlass2(){
                    arView.scene.anchors.removeAll()
                    arView.scene.addAnchor(g)
                }
                
            case 1:
                if let g = try? FaceMask.loadIndian() {
                    arView.scene.anchors.removeAll()
                    arView.scene.addAnchor(g)
                }
                
            case 2:
                if let g = try? FaceMask.loadRabbit() {
                    arView.scene.anchors.removeAll()
                    arView.scene.addAnchor(g)
                }
                
            case 3:
                if let g = try? FaceMask.loadHelicopterPilot() {
                    arView.scene.anchors.removeAll()
                    arView.scene.addAnchor(g)
                }
                
            case 4:
                if let g = try? FaceMask.loadGlass1() {
                    arView.scene.anchors.removeAll()
                    arView.scene.addAnchor(g)
                }
                
            default:
                break
            }
        }
    }
    
   
}
struct  FaceCheckingContainer: UIViewRepresentable {
    
    @Binding var faceMetre: Bool
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        guard ARFaceTrackingConfiguration.isSupported else {
            return
        }
        if faceMetre {}
       
        let config = ARFaceTrackingConfiguration()

        config.isWorldTrackingEnabled = false
        config.providesAudioData = false
        config.maximumNumberOfTrackedFaces =  1
        config.isLightEstimationEnabled = true
        uiView.delegate = context.coordinator
        
        uiView.session.run(config,options: [.resetTracking, .removeExistingAnchors])
    }
    
    func makeCoordinator() -> FaceCheckingContainerCoordinator {
        FaceCheckingContainerCoordinator(self)
    }
    
    class FaceCheckingContainerCoordinator: NSObject, ARSessionDelegate,ARSCNViewDelegate {
        
        
        var parent : FaceCheckingContainer
        init(_ parent: FaceCheckingContainer) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            guard  let device = renderer.device  else {
                return nil
            }
            let faceGeometry = ARSCNFaceGeometry(device: device)
            let node = SCNNode(geometry: faceGeometry)
            
            if parent.faceMetre {
                //显示图片面具
                let matrial = node.geometry?.firstMaterial
                matrial?.diffuse.contents =  "face.scnassets/face.png"
                node.geometry?.firstMaterial?.fillMode = .fill
            }else {
                //显示网格
                node.geometry?.firstMaterial?.fillMode = .lines
            }
          
            return node
        }
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceanchor = anchor as? ARFaceAnchor,
                  let facegeometry = node.geometry as? ARSCNFaceGeometry else {
                return
            }
            facegeometry.update(from: faceanchor.geometry)
        }
    }
    
    
}

