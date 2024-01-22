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

struct BoneAnimationView : View {
    var body: some View {
        return ARViewContainer9().edgesIgnoringSafeArea(.all).navigationTitle("AR骨骼动画")
    }
}

struct ARViewContainer9: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options:[ ])
        arView.session.delegate = arView
        arView.CreateRobot()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

extension ARView{
    func CreateRobot(){
        let planeAnchor = AnchorEntity(plane:.horizontal)
        do {
            let robot =  try ModelEntity.load(named: "toy_drummer")
            planeAnchor.addChild(robot)
            robot.scale = [0.01,0.01,0.01]
            self.scene.addAnchor(planeAnchor)
            print("Total animation count : \(robot.availableAnimations.count)")
            robot.playAnimation(robot.availableAnimations[0].repeat())
        } catch {
            print("找不到USDZ文件")
        }
    }
}


#if DEBUG
struct BoneAnimationView_Previews : PreviewProvider {
    static var previews: some View {
        BoneAnimationView()
    }
}
#endif
