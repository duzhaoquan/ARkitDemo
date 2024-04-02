//
//  Text3DView.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/3/21.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

struct Text3DView: View {
    @State var change: String = "中文汉字"
    var body: some View {
        Text3DViewContainer(change: change)
            .overlay(
                VStack{
                    Spacer()
                    TextField( LocalizedStringKey(""), text: $change)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .frame(width:300,height:50)
                        .cornerRadius(5)
                        .opacity(0.6)
                    
                    .offset(y:-330)
                    .padding(.bottom, 300)
                }
        ).navigationTitle("3D文字").edgesIgnoringSafeArea(.all)
    }
}

struct Text3DViewContainer:UIViewRepresentable {
    var change:String = ""
    func makeUIView(context: Context) -> some ARView {
        let arView = ARView(frame: .zero)
        context.coordinator.arView = arView
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        context.coordinator.createPlane()
        arView.session.run(config)
        
        
            
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if !change.isEmpty {
            context.coordinator.chengeText(text: change)
        }
    }
    
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var arView: ARView!
        var text: String = ""
        var textEntity: ModelEntity!
        func createPlane() {
            let planeAnchor = AnchorEntity(plane: .horizontal)

            let textr = MeshResource.generateText("中文汉字",
                                                  extrusionDepth: 0.05,
                                                  font: .systemFont(ofSize: 15),
                                                  containerFrame: .zero,
                                                  alignment: .left,
                                                  lineBreakMode: .byWordWrapping)
            
            let textMetiral = SimpleMaterial(color: .red, isMetallic: true)
            textEntity = ModelEntity(mesh: textr, materials: [textMetiral])
            textEntity.generateCollisionShapes(recursive: false)
            
            planeAnchor.addChild(textEntity)
            arView.scene.addAnchor(planeAnchor)
            arView.installGestures(.all, for: textEntity)
        }
        func chengeText(text: String) {
            let planeAnchor = AnchorEntity(plane: .horizontal)

            let textr = MeshResource.generateText(text,
                                                  extrusionDepth: 0.05,
                                                  font: .systemFont(ofSize: 2),
                                                  containerFrame: .zero,
                                                  alignment: .left,
                                                  lineBreakMode: .byWordWrapping)
            
            let textMetiral = SimpleMaterial(color: .red, isMetallic: true)
            textEntity.removeFromParent()
            textEntity = ModelEntity(mesh: textr, materials: [textMetiral])
            textEntity.generateCollisionShapes(recursive: false)
            
            planeAnchor.addChild(textEntity)
            arView.scene.addAnchor(planeAnchor)
            arView.installGestures(.all, for: textEntity)
        }
        
    }
}
#Preview {
    Text3DView()
}
