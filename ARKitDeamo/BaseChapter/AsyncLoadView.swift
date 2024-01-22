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
import Combine

struct AsyncLoadView : View {
    var body: some View {
        return ARViewContainer10().edgesIgnoringSafeArea(.all).navigationTitle("AR同步加载与异步加载")
    }
}

struct ARViewContainer10: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        
        config.planeDetection = .horizontal
        config.worldAlignment = .gravity
        arView.session.run(config, options:[ ])
        //arView.session.delegate = arView
        
        arView.loadModel()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

extension ARView{
    func loadModel(){
        let planeAnchor = AnchorEntity(plane:.horizontal)
        //同步加载
        do {
            let usdzPath = "toy_drummer"
            let modelEntity =  try ModelEntity.loadModel(named: usdzPath)
            print("加载成功！")
            planeAnchor.addChild(modelEntity)
            self.scene.addAnchor(planeAnchor)
            self.installGestures(.all, for: modelEntity)
        } catch {
            print("找不到文件")
        }
        //异步加载
        
//        let usdzPath = "toy_drummer"
//        var cancellable: AnyCancellable? = nil
//        cancellable = ModelEntity.loadModelAsync(named: usdzPath)
//            .sink(receiveCompletion: { error in
//                print("发生错误: \(error)")
//                cancellable?.cancel()
//            }, receiveValue: { entity in
//                planeAnchor.addChild(entity)
//                cancellable?.cancel()
//            })
//        
//        self.scene.addAnchor(planeAnchor)
    }
}

#if DEBUG
struct AsyncLoadView_Previews : PreviewProvider {
    static var previews: some View {
        ARViewContainer10()
    }
}
#endif
