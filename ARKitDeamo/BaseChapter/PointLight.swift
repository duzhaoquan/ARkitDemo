//
//  PointLightView.swift
//  ARKitDeamo
//
//  Created by Zhaoquan on 2023/1/7.
//

import SwiftUI
import RealityKit
import ARKit

struct PointLightView : View {
    var body: some View {
        return ARViewContainer12().edgesIgnoringSafeArea(.all).navigationTitle("点光")
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



extension ARView {
    func createPlane12(){
        let planeAnchor = AnchorEntity(plane:.horizontal,classification: .any,minimumBounds: [0.3,0.3])
        
        let planeMesh = MeshResource.generatePlane(width: 0.8,depth: 0.8)
        let planeMaterial = SimpleMaterial(color:.white,isMetallic: false)
        let planeEntity = ModelEntity(mesh:planeMesh,materials:[planeMaterial])
        planeAnchor.addChild(planeEntity)
        
        let boxMesh = MeshResource.generateBox(size: 0.1)
        let boxMaterial = SimpleMaterial(color:.white,isMetallic: false)
        let boxEntity = ModelEntity(mesh:boxMesh,materials:[boxMaterial])
        planeAnchor.addChild(boxEntity)
        //添加点光源
        let l = PointLight()
        l.light = PointLightComponent(color: .green, intensity: 5000, attenuationRadius: 0.5)
        l.position = [planeEntity.position.x , planeEntity.position.y + 0.5,planeEntity.position.z+0.2]
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
