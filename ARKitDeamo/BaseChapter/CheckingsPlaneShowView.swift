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

struct CheckingsPlaneShowView: View {
    var body: some View {
        return ARViewContainer4().edgesIgnoringSafeArea(.all).navigationTitle("AR平面监测")
    }
}

struct ARViewContainer4: UIViewRepresentable {
    let arView = ARView(frame: .zero)
    let dele = ARViewDelegate()
    func makeUIView(context: Context) -> ARView {
        
        let config = ARWorldTrackingConfiguration()
        //检测水平平面
        config.planeDetection = .horizontal
        
        arView.session.run(config, options:[ ])
        arView.session.delegate = dele
        createPlane()
        return arView
    }
    func createPlane(){
        let planeAnchor = AnchorEntity(plane:.horizontal)
        do {
            //texture(.load(named: "Surface_DIFFUSE.png")
            dele.planeMaterial.color = try SimpleMaterial.BaseColor(tint:UIColor.yellow.withAlphaComponent(0.9999), texture: MaterialParameters.Texture(TextureResource.load(named: "Surface_DIFFUSE.png")))
            dele.planeEntity  = ModelEntity(mesh:dele.planeMesh,materials:[dele.planeMaterial])
            dele.planeAnchor.addChild(dele.planeEntity!)
            arView.scene.addAnchor(planeAnchor)
        } catch {
            print("找不到文件")
        }
    }
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}



class ARViewDelegate :NSObject, ARSessionDelegate,ARSessionObserver{
    
    var planeMesh = MeshResource.generatePlane(width: 0.15, depth: 0.15)
    var planeMaterial = SimpleMaterial(color:.white,isMetallic: false)
    var planeEntity: ModelEntity?
    var planeAnchor = AnchorEntity()
    

    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]){
       guard let pAnchor = anchors[0] as? ARPlaneAnchor else {
          return
        }
        DispatchQueue.main.async {
            self.planeEntity!.model?.mesh = MeshResource.generatePlane(
                width: pAnchor.planeExtent.width,
                depth: pAnchor.planeExtent.height
            )
            self.planeEntity!.setTransformMatrix(pAnchor.transform, relativeTo: nil)
        }
    }
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]){
       guard let pAnchor = anchors[0] as? ARPlaneAnchor else {
          return
        }
        DispatchQueue.main.async {
            self.planeEntity!.model?.mesh = MeshResource.generatePlane(
                width: pAnchor.planeExtent.width,
                depth: pAnchor.planeExtent.height
            )
            self.planeEntity!.setTransformMatrix(pAnchor.transform, relativeTo: nil)
        }
    }
}



