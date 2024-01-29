//
//  DirectionalLightView.swift
//  ARKitDeamo
//
//  Created by Zhaoquan on 2023/1/7.
//

import SwiftUI
import RealityKit
import ARKit

struct DirectionalLightView : View {
    var body: some View {
        return ARViewContainer11().edgesIgnoringSafeArea(.all).navigationTitle("平行光")
    }
}

struct ARViewContainer11: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        config.worldAlignment = .gravity
        arView.session.run(config, options:[ ])
        arView.session.delegate = arView
        arView.createPlane11()
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

var boxMesh = MeshResource.generateBox(size: 0.1)
var boxMaterial = SimpleMaterial(color:.white,isMetallic: false)
var boxEntity11 = ModelEntity(mesh:boxMesh,materials:[boxMaterial])

var planeMesh11 = MeshResource.generatePlane(width: 0.3,depth: 0.3)
var planeMaterial11 = SimpleMaterial(color:.white,isMetallic: false)
var planeEntity11 = ModelEntity(mesh:planeMesh11,materials:[planeMaterial11])

extension ARView {
    func createPlane11(){
        let planeAnchor = AnchorEntity(plane:.horizontal,classification: .any,minimumBounds: [0.3,0.3])
        planeAnchor.addChild(boxEntity11)
        var tf = boxEntity11.transform
        tf.translation = SIMD3(tf.translation.x,tf.translation.y + 0.06,tf.translation.z)
        boxEntity11.move(to: tf, relativeTo: nil)
        planeAnchor.addChild(planeEntity11)
        
        //添加平行光源
        let directionalLight = DirectionalLight()
        //光照强度
        directionalLight.light.intensity = 50000
        //光照颜色
        directionalLight.light.color = UIColor.red
        directionalLight.light.isRealWorldProxy = false
        
        directionalLight.look(at: [0, 0, 0], from: [0.01, 1, 0.01], relativeTo: nil)
        planeAnchor.addChild(directionalLight)
        self.scene.addAnchor(planeAnchor)
    }
}


#if DEBUG
struct DirectionalLightView_Previews : PreviewProvider {
    static var previews: some View {
        ARViewContainer11()
    }
}
#endif
