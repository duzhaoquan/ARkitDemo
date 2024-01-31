//
//  ManualEnvirmentTexturing.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/30.
//

import SwiftUI
import ARKit
import RealityKit

struct ManualEnvirmentTexturing: View {
    @State var automatic: Bool = true
    var body: some View {
        ManualEnvirmentTexturingContainer(automatic: $automatic)
            .overlay(content: {
               
                VStack {
                    Spacer()
                    HStack{
                        Text(automatic ? "HDR" : "HDR Off")
                            .background(GeometryReader{ _ in
                                Color.white
                            })
                            .padding(10)
                            .offset(x: 0)
                        Toggle(isOn: $automatic) {}
                            .frame(width: 50)
                            .offset(x: 0)
                    }
                    
                    Spacer().frame(height: 40)
                }
                

            })
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("环境探头")
        
    }
       
}

struct ManualEnvirmentTexturingContainer:UIViewRepresentable {
    @Binding var automatic: Bool
    func makeUIView(context: Context) -> ARView
    {
        let arView = ARView(frame: .zero)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        
        config.environmentTexturing = .manual
        
        context.coordinator.arView = uiView
        uiView.session.delegate = context.coordinator
        
        if automatic {
           
            config.wantsHDREnvironmentTextures = true
            
        }else{
            config.wantsHDREnvironmentTextures = false
        }
        uiView.session.run(config, options: [])
       
        
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject,ARSessionDelegate {
        var manualProbe: ManualProbe?
        var arView: ARView? = nil
        var parent: ManualEnvirmentTexturingContainer
        init(parent: ManualEnvirmentTexturingContainer) {
            self.parent = parent
        }
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let anchor = anchors.first as? ARPlaneAnchor else {
                return
            }
            //球体
            let mesh = MeshResource.generateSphere(radius: 0.05)
            let meterial = SimpleMaterial(color: .blue, isMetallic: true)
            let modelEntity = ModelEntity(mesh: mesh, materials: [meterial])
            
           
            
            let planAnchor = AnchorEntity(anchor: anchor)
            //放在正上方5cm处
            modelEntity.transform.translation = [0, planAnchor.transform.translation.y + 0.05,0]
            manualProbe = ManualProbe(shpereEntity: modelEntity)
            
            updateProbe()
            planAnchor.addChild(manualProbe!.shpereEntity)
            arView?.scene.addAnchor(planAnchor)
            
            //只添加一次
            session.delegate = nil
            session.run(ARWorldTrackingConfiguration())
            
            manualProbe?.isPlaced = true
        }
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            if let manualProbe = manualProbe,
                manualProbe.requireRefresh,
                Date().timeIntervalSince1970 - manualProbe.lastUpadateTime > 1{
                
                self.manualProbe?.lastUpadateTime = Date().timeIntervalSince1970
                updateProbe()
                
            }
        }
        
        
        func  updateProbe() {
            guard let manualProbe = manualProbe else {
                return
            }
            //移除旧的
            if let probAnchor = manualProbe.objectProbeAnchor {
                self.arView?.session.remove(anchor: probAnchor)
                self.manualProbe?.objectProbeAnchor = nil
            }
            
            var extent = (manualProbe.shpereEntity.model?.mesh.bounds.extents)! * manualProbe.shpereEntity.transform.scale
            extent.x *= 3
            extent.y *= 3
            extent.z *= 2
            
//            let verticalOffset = SIMD3(0, extent.y, 0)
//            var probeTransform = manualProbe.shpereEntity.transform
//            probeTransform.translation += verticalOffset
            
            let  position = simd_float4x4(
               
                SIMD4(1,0,0,0),
                SIMD4(0,1,0,0),
                SIMD4(0,0,1,0),
                SIMD4(manualProbe.shpereEntity.transform.translation,1)
                        
            )
            
            self.manualProbe?.objectProbeAnchor = AREnvironmentProbeAnchor(name: "objectProbe",transform: position, extent:extent)
            self.arView?.session.add(anchor: (self.manualProbe?.objectProbeAnchor)!)
        }
    }
    
    
    
}


struct ManualProbe {
    var objectProbeAnchor: AREnvironmentProbeAnchor?
    var requireRefresh = true
    var lastUpadateTime = Date().timeIntervalSince1970
    var dateTime = Date()
    var shpereEntity: ModelEntity
    var isPlaced = false
}
