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

struct ARGescherView : View {
    var body: some View {
        return ARViewContainer2().edgesIgnoringSafeArea(.all).navigationTitle("AR简单的手势操作")
    }
}

struct ARViewContainer2: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options:[ ])
        arView.session.delegate = arView
        arView.createPlane2()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}


extension ARView {
    
    func createPlane2(){
        let planeAnchor = AnchorEntity(plane:.horizontal)
        do {
            let cubeMesh = MeshResource.generateBox(size: 0.1)
            var cubeMaterial = SimpleMaterial(color:.white,isMetallic: false)
            cubeMaterial.color = try SimpleMaterial.BaseColor(tint:UIColor.yellow.withAlphaComponent(0.9999), texture: MaterialParameters.Texture(TextureResource.load(named: "Box_Texture.jpg")))
            let cubeEntity = ModelEntity(mesh:cubeMesh,materials:[cubeMaterial])
            cubeEntity.generateCollisionShapes(recursive: false)
            planeAnchor.addChild(cubeEntity)
            self.scene.addAnchor(planeAnchor)
            self.installGestures(.all,for:cubeEntity)
        } catch {
            print("找不到文件")
        }
    }
}




