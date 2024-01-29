//
//  SpotLightView.swift
//  ARKitDeamo
//
//  Created by Zhaoquan on 2023/1/7.
//


import SwiftUI
import RealityKit
import ARKit

struct SpotLightView : View {
    var body: some View {
        return ARViewContainer12().edgesIgnoringSafeArea(.all).navigationTitle("聚光")
    }
}

struct ARViewContainer13: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        config.worldAlignment = .gravity
        arView.session.run(config, options:[ ])
        arView.session.delegate = arView
        arView.createPlane13()
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}
/*
class SpotLight: Entity, HasSpotLight {

    required init() {
        super.init()
        self.light = SpotLightComponent(color: .yellow,intensity: 50000, innerAngleInDegrees: 60,outerAngleInDegrees: 130,attenuationRadius: 5)
    }
}
 */

var planeMesh13 = MeshResource.generatePlane(width: 0.8,depth: 0.8)
var planeMaterial13 = SimpleMaterial(color:.white,isMetallic: false)
var planeEntity13 = ModelEntity(mesh:planeMesh13,materials:[planeMaterial13])

extension ARView : ARSessionDelegate{
    func createPlane13(){
        let planeAnchor = AnchorEntity(plane:.horizontal,classification: .any,minimumBounds: [0.3,0.3])
        planeAnchor.addChild(planeEntity13)
        let l = SpotLight()
        l.light = SpotLightComponent(color: .yellow, intensity: 5000, innerAngleInDegrees: 5, outerAngleInDegrees: 80, attenuationRadius: 2)
        l.position = [planeEntity13.position.x , planeEntity13.position.y + 0.1,planeEntity13.position.z+0.5]
        l.move(to: l.transform, relativeTo: nil)
        let lightAnchor = AnchorEntity(world: l.position)
        l.look(at: planeEntity13.position, from: l.position, relativeTo: nil)
        lightAnchor.components.set(l.light)
        self.scene.addAnchor(lightAnchor)
        self.scene.addAnchor(planeAnchor)
    }
}


#if DEBUG
struct SpotLightView_Previews : PreviewProvider {
    static var previews: some View {
        ARViewContainer13()
    }
}
#endif
