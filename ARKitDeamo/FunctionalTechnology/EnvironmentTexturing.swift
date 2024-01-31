//
//  EnvironmentTexturing.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/30.
//

import SwiftUI
import ARKit
import RealityKit


struct TextWidthtKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct EnvironmentTexturing: View {
    @State var automatic: Bool = true
    @State var textWidth: CGFloat = 0
    var body: some View {
        GeometryReader { ge in
            EnvironmentTexturingContainer(automatic: $automatic)
                .overlay(content: {
                   
                    VStack {
                        Spacer()
                        HStack{
                            Text(automatic ? "自动环境探头" : "不使用环境探头")
                                
                                .background(GeometryReader {_ in 
                                    Color.white
                                        //.preference(key: TextWidthtKey.self, value: $0.frame(in: .local).size.width)
                                })
//                                .onPreferenceChange(TextWidthtKey.self, perform: { width in
//                                    print("----------------w: \(ge.size.width), tw: \(width)")
//                                    self.textWidth = width
//                                })
                                .padding(10)
                                .offset(x: 0 )
                            
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
}

struct EnvironmentTexturingContainer : UIViewRepresentable{
    
    @Binding var automatic: Bool
    func makeUIView(context: Context) -> ARView
    {
        let arView = ARView(frame: .zero)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        if automatic {
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = .horizontal
            
            config.environmentTexturing = .automatic
            config.wantsHDREnvironmentTextures = true
            
            context.coordinator.arView = uiView
            uiView.session.delegate = context.coordinator
            uiView.automaticallyConfigureSession = false
            uiView.session.run(config, options: [.resetTracking,.removeExistingAnchors])
            return
        }else{
            let config = ARWorldTrackingConfiguration()
            config.planeDetection = .horizontal
            
            config.environmentTexturing = .none
            
            context.coordinator.arView = uiView
            uiView.session.delegate = context.coordinator
            
            uiView.session.run(config, options: [.resetTracking,.removeExistingAnchors])
        }
        
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject,ARSessionDelegate {
        var arView: ARView? = nil
        var parent: EnvironmentTexturingContainer
        init(parent: EnvironmentTexturingContainer) {
            self.parent = parent
        }
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let anchor = anchors.first as? ARPlaneAnchor else {
                return
            }
            let mesh = MeshResource.generateSphere(radius: 0.1)
            let meterial = SimpleMaterial(color: .blue, isMetallic: true)
            
            
            let modelEntity = ModelEntity(mesh: mesh, materials: [meterial])
            
            let planAnchor = AnchorEntity(anchor: anchor)
            //放在正上方
            modelEntity.transform.translation = [0, planAnchor.transform.translation.y + 0.05,0]
            
            planAnchor.addChild(modelEntity)
            arView?.scene.addAnchor(planAnchor)
            
            //只添加一次
            session.delegate = nil
            session.run(ARWorldTrackingConfiguration())
            
        }
    }
    
}
