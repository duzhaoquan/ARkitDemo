//
//  BlendShapeRobot.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/25.
//

import SwiftUI
import ARKit
import RealityKit

struct BlendShapeRobot: View {
    var body: some View {
        BlendShapeRobotContainer().edgesIgnoringSafeArea(.all)
    }
}

struct BlendShapeRobotContainer :UIViewRepresentable{
    
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        return arView
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard ARFaceTrackingConfiguration.isSupported else {
            return
        }
        let config = ARWorldTrackingConfiguration()
        config.userFaceTrackingEnabled = true
        config.isLightEstimationEnabled = true
        config.worldAlignment = .gravity
        
        config.planeDetection = .horizontal
        
        uiView.session.delegate = context.coordinator
        uiView.automaticallyConfigureSession = false
        uiView.session.run(config, options: [])
        let planeAnchor = AnchorEntity(plane:.horizontal)
        planeAnchor.addChild(context.coordinator.robotHead)
        uiView.scene.addAnchor(planeAnchor)
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSessionDelegate{
        var robotHead = RobotHead()
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            for anchor in anchors {
                guard  let anchor = anchor as? ARFaceAnchor else {
                    continue
                }
                robotHead.update(with: anchor)
            }
        }
        
       
    }
    
}
