//
//  ContentView.swift
//  Chapter1
//
//  Created by Davidwang on 2020/2/27.
//  Copyright © 2020 Davidwang. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct GestureControlView : View {
    var body: some View {
        return ARViewContainer6().edgesIgnoringSafeArea(.all).navigationTitle("AR手势控制")
    }
}

struct ARViewContainer6: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options:[ ])
        arView.session.delegate = arView
        arView.createPlane1()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}
var cubeEntity1 : ModelEntity?
var gestureStartLocation1: SIMD3<Float>?

extension ARView {
    
    func createPlane1(){
        let planeAnchor = AnchorEntity(plane:.horizontal)
        do {
            let cubeMesh = MeshResource.generateBox(size: 0.1)
            var cubeMaterial = SimpleMaterial(color:.white,isMetallic: false)
            cubeMaterial.color = try SimpleMaterial.BaseColor(tint:UIColor.yellow.withAlphaComponent(0.9999), texture: MaterialParameters.Texture(TextureResource.load(named: "Box_Texture.jpg")))
            cubeEntity1 = ModelEntity(mesh:cubeMesh,materials:[cubeMaterial])
            cubeEntity1!.generateCollisionShapes(recursive: false)
            cubeEntity1?.name = "this is a cube"
            planeAnchor.addChild(cubeEntity1!)
            self.scene.addAnchor(planeAnchor)
            self.installGestures(.all,for:cubeEntity1!).forEach{
                     $0.addTarget(self, action: #selector(handleModelGesture1))
                }
        } catch {
            print("找不到文件")
        }
    }
    
    @objc func handleModelGesture1(_ sender: Any) {
        switch sender {
        case let rotation as EntityRotationGestureRecognizer:
            print("Rotation and name :\(rotation.entity!.name)")
//            rotation.isEnabled = false
//            var transform = rotation.entity!.transform
//            transform.rotation = simd_quatf(angle: Float.pi * 0.5, axis: [0,0,1])
//            rotation.entity?.move(to: transform, relativeTo: nil, duration: 5.0)
//            rotation.isEnabled = true
        case let translation as EntityTranslationGestureRecognizer:
            print("translation and name \(translation.entity!.name)")
            if translation.state == .ended || translation.state == .cancelled {
                gestureStartLocation1 = nil
                return
            }
            guard let gestureCurrentLocation = translation.entity?.transform.translation else { return }
            guard let _ = gestureStartLocation1 else {
                gestureStartLocation1 = gestureCurrentLocation
                return
            }
            let delta = gestureStartLocation1! - gestureCurrentLocation
            let distance = ((delta.x * delta.x) + (delta.y * delta.y) + (delta.z * delta.z)).squareRoot()
            print("startLocation:\(String(describing: gestureStartLocation1)),currentLocation:\(gestureCurrentLocation),the distance is \(distance)")
            
        case let scale1 as EntityScaleGestureRecognizer:
            if let scale = scale1.entity?.scale{
                cubeEntity1?.scale = scale
            }
        default:
            break
        }
    }

}

