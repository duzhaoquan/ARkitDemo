//
//  ContentView.swift
//  Chapter3
//
//  Created by Davidwang on 2020/3/7.
//  Copyright © 2020 Davidwang. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit

struct PointLightView : View {
    var body: some View {
        return ARViewContainer12().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer12: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        config.worldAlignment = .gravity
        arView.session.run(config, options:[ ])
        arView.session.delegate = arView
        arView.createPlane12()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

var planeMesh12 = MeshResource.generatePlane(width: 0.8,depth: 0.8)
var planeMaterial12 = SimpleMaterial(color:.white,isMetallic: false)
var planeEntity12 = ModelEntity(mesh:planeMesh12,materials:[planeMaterial12])

extension ARView {
    func createPlane12(){
        let planeAnchor = AnchorEntity(plane:.horizontal,classification: .any,minimumBounds: [0.3,0.3])
        planeAnchor.addChild(planeEntity12)
        let l = PointLight()
        l.light = PointLightComponent(color: .green, intensity: 5000, attenuationRadius: 0.5)
        l.position = [planeEntity12.position.x , planeEntity12.position.y + 0.1,planeEntity12.position.z+0.2]
        l.move(to: l.transform, relativeTo: nil)
        let lightAnchor = AnchorEntity(world: l.position)
        lightAnchor.components.set(l.light)
        self.scene.addAnchor(lightAnchor)
        self.scene.addAnchor(planeAnchor)
    }
}


#if DEBUG
struct PointLightView_Previews : PreviewProvider {
    static var previews: some View {
        ARViewContainer12()
    }
}
#endif
