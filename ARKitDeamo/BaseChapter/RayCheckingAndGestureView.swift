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

struct RayCheckingAndGestureView : View {
    var body: some View {
        return ARViewContainer5().edgesIgnoringSafeArea(.all).navigationTitle("AR射线检测与手势操作")
    }
}

struct ARViewContainer5: UIViewRepresentable {
    let arView = ARView(frame: .zero)
    let dele = ARViewSessionDelegate()
    
    func makeUIView(context: Context) -> ARView {
        
        
        dele.containner = self
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options:[ ])
        arView.session.delegate = dele
        createPlane()
        arView.setupGestures1()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
    
    func createPlane(){
        func createPlane(){
            let planeAnchor = AnchorEntity(plane:.horizontal)
            do {
                planeMaterial1.color = try SimpleMaterial.BaseColor(tint:UIColor.yellow.withAlphaComponent(0.9999), texture: MaterialParameters.Texture(TextureResource.load(named: "AR_Placement_Indicator.png")))
                planeAnchor.addChild(planeEntity1)
                self.arView.scene.addAnchor(planeAnchor)
            } catch {
                print("找不到文件")
            }
        }
    }
    
    
}

var planeMesh1 = MeshResource.generatePlane(width: 0.15, depth: 0.15)
var planeMaterial1 = SimpleMaterial(color:.white,isMetallic: false)
var planeEntity1 : ModelEntity = ModelEntity(mesh:planeMesh1,materials:[planeMaterial1])
var planeAnchor1 = AnchorEntity()
var objectPlaced1 = false
var raycastResult1 : ARRaycastResult?


extension ARView {
    func setupGestures1() {
        
      let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap1))
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap1(_ sender: UITapGestureRecognizer? = nil) {
        if objectPlaced1 {return}
        
        let cubeMesh = MeshResource.generateBox(size: 0.1)
        let cubeMaterial = SimpleMaterial(color:.red,isMetallic: false)
        let cubeEntity = ModelEntity(mesh:cubeMesh,materials:[cubeMaterial])
        if let raycastResult1 = raycastResult1{
            let cubeAnchor = AnchorEntity(raycastResult:raycastResult1)
            cubeAnchor.addChild(cubeEntity)
            scene.addAnchor(cubeAnchor)
            planeEntity1.removeFromParent()
            objectPlaced1 = true
        }
        

    }
}

class ARViewSessionDelegate : NSObject, ARSessionDelegate{
    
    var containner: ARViewContainer5?
    
    public func session(_ session: ARSession, didUpdate frame: ARFrame){
        if objectPlaced1 {return}
        guard let arView = containner?.arView, let result = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal).first else {
            return
        }
        raycastResult1 = result
        planeEntity1.setTransformMatrix(result.worldTransform, relativeTo: nil)
    }
/*
    public func session(_ session: ARSession, didUpdate frame: ARFrame){
        if objectPlaced {return}
        guard let raycastQuery = self.makeRaycastQuery(from: self.center,
                                                     allowing: .estimatedPlane,
                                                    alignment: .horizontal) else {
            return
        }

        guard let result = self.session.raycast(raycastQuery).first else {
            return
        }
        raycastResult = result
        planeEntity!.setTransformMatrix(result.worldTransform, relativeTo: nil)
    }
    */
   
}


