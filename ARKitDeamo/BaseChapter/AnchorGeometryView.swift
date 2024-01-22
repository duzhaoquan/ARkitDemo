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

struct AnchorGeometryView : View {
    var body: some View {
        return ARViewContainer7().edgesIgnoringSafeArea(.all).navigationTitle("AR显示世界坐标系")
    }
}

struct ARViewContainer7: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        arView.automaticallyConfigureSession = false
        
        let config = ARWorldTrackingConfiguration()
        //pro 才支持这个,场景重建
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.meshWithClassification) {
            config.sceneReconstruction = .meshWithClassification
        }
        //是否支持景深
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics = .sceneDepth
        }
        config.planeDetection = [.vertical,.horizontal]
        arView.session.run(config, options:[ .resetSceneReconstruction])
        arView.debugOptions = [.showAnchorOrigins,.showPhysics,.showSceneUnderstanding]
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}


