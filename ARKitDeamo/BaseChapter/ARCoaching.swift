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

struct ARCoachingView : View {
    var body: some View {
        return ARViewContainer1().edgesIgnoringSafeArea(.all).navigationTitle("AR引导图")
    }
}

struct ARViewContainer1: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options:[ ])
        arView.addCoaching()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

extension ARView: ARCoachingOverlayViewDelegate{
    
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(coachingOverlay)
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.session = self.session
        coachingOverlay.delegate = self
    }
    public func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
      self.placeBox()
    }
    @objc func placeBox(){
        let boxMesh = MeshResource.generateBox(size: 0.15)
        var boxMaterial = SimpleMaterial(color:.white,isMetallic: false)
        let planeAnchor = AnchorEntity(plane:.horizontal)
        do {
            boxMaterial.color = try SimpleMaterial.BaseColor(tint:UIColor.yellow.withAlphaComponent(0.9999), texture: MaterialParameters.Texture(TextureResource.load(named: "Box_Texture.jpg")))
            let boxEntity  = ModelEntity(mesh:boxMesh,materials:[boxMaterial])
            planeAnchor.addChild(boxEntity)
            self.scene.addAnchor(planeAnchor)
        } catch {
            print("找不到文件")
        }
    }
    
}



