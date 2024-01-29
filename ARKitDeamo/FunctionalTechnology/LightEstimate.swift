//
//  LightEstimate.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/29.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

struct LightEstimate: View {
    @State var isFaceTracking = false
    var body: some View {
        LightEstimateContainer(isFaceTracking: isFaceTracking)
            .overlay(content: {
                VStack{
                    Spacer()
                    
                        Button {
                            isFaceTracking.toggle()
                        } label: {
                            
                            Text( !isFaceTracking ? "人脸追踪光照": "普通光照估计")
                                .frame(width:150,height:50)
                                .font(.system(size: 17))
                                .foregroundColor(.black)
                                .background(Color.white)
                            
                                .opacity(0.6)
                                
                        }
                            
                        .cornerRadius(10)
                        Spacer().frame(height: 40)
                    
                    

                }
            })
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("光照估计")
    }
}

struct LightEstimateContainer: UIViewRepresentable {
    var isFaceTracking: Bool = false
    init(isFaceTracking: Bool = false) {
        self.isFaceTracking = isFaceTracking
    }
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if isFaceTracking {
            
            let config = ARFaceTrackingConfiguration()
            config.isLightEstimationEnabled = true
            uiView.session.delegate = context.coordinator
            context.coordinator.times = 0
            uiView.session.run(config, options: [.resetTracking,.removeExistingAnchors])
            return
        }
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        config.isLightEstimationEnabled = true
        
        context.coordinator.arView = uiView
        uiView.session.delegate = context.coordinator
        uiView.session.run(config)
        
        
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    
    class  Coordinator: NSObject,ARSessionDelegate {
        var arView:ARView? = nil
        var isPlaced = false
        var times = 0
        var parent: LightEstimateContainer
        init(parent: LightEstimateContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let anchor = anchors.first as? ARPlaneAnchor,!isPlaced else {
                return
            }
            do {
                let planEntity = AnchorEntity(anchor: anchor)
                let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.003)
                let texture = MaterialParameters.Texture.init(try TextureResource.load(named: "Box_Texture.jpg"))
                var meterial = SimpleMaterial(color: .blue,roughness: 0.8 ,isMetallic: false)
                meterial.color = .init(tint:.blue,texture:texture)
                
                let modelEntity = ModelEntity(mesh: mesh, materials: [meterial])
                planEntity.addChild(modelEntity)
                
                arView?.installGestures(for:modelEntity)
                arView?.scene.addAnchor(planEntity)
                
            }catch{
                print("无法加载纹理")
            }
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard let estimatLight = frame.lightEstimate , times < 10 else {return }
            print("light intensity: \(estimatLight.ambientIntensity),light temperature: \(estimatLight.ambientColorTemperature)")
            if let estimatLight = frame.lightEstimate as? ARDirectionalLightEstimate {
                print("primary light direction: \(estimatLight.primaryLightDirection), primary light intensity: \(estimatLight.primaryLightIntensity)")
            }
            times += 1
            
        }
    }
}
