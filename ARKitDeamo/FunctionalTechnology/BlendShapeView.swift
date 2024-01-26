//
//  BlendShapeView.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/25.
//

import SwiftUI
import ARKit
import RealityKit


struct BlendShapeView: View {
    var body: some View {
        BlendShapeViewContainer().edgesIgnoringSafeArea(.all).navigationTitle("BlendShape")
    }
}

struct BlendShapeViewContainer :UIViewRepresentable{
    
    
    func makeUIView(context: Context) -> ARSCNView {
        let arSCNView = ARSCNView(frame: .zero)
        return arSCNView
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard ARFaceTrackingConfiguration.isSupported else {
            return
        }
        let config = ARFaceTrackingConfiguration()
        config.isWorldTrackingEnabled = false
        config.isLightEstimationEnabled = true
        config.maximumNumberOfTrackedFaces = 1
        config.providesAudioData = false
        
        uiView.delegate = context.coordinator
        uiView.autoenablesDefaultLighting = true
        uiView.allowsCameraControl = true
        uiView.session.run(config, options: [])
        
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate{
        var contentNode: SCNReferenceNode? = nil
        private lazy var head = contentNode?.childNode(withName: "head", recursively: true)
        func modelSetup() {
            if let filePath = Bundle.main.path(forResource: "BlendShapeFace", ofType: "scn") {
                let referenceURL = URL(fileURLWithPath: filePath)
                self.contentNode = SCNReferenceNode(url: referenceURL)
                self.contentNode?.load()
                self.head?.morpher?.unifiesNormals = true
                self.contentNode?.scale = SCNVector3(0.01,0.01,0.01)
                self.contentNode?.position.x += 0.2
            }
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            guard anchor is ARFaceAnchor else{
                return
            }
            modelSetup()
            if let contentNode = contentNode {
                node.addChildNode(contentNode)
            }
            
            
        }
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            DispatchQueue.main.async {
                for (key, value) in faceAnchor.blendShapes {
                    if let fValue = value as? Float {
                        self.head?.morpher?.setWeight(CGFloat(fValue), forTargetNamed: key.rawValue)
                    }
                }
            }
        }
        
    }
    
}
