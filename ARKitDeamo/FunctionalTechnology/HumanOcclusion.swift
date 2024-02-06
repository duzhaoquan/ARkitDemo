//
//  HumanOcclusion.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/2/4.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

//HumanExtraction
struct HumanOcclusionView: View {
    
    var body: some View {
        HumanOcclusionContainer().edgesIgnoringSafeArea(.all).navigationTitle("人形遮挡")
    }
}

struct HumanOcclusionContainer: UIViewRepresentable {
    
    
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            print("不支持人形遮挡")
            return arView
        }
        
        let config = ARWorldTrackingConfiguration()
        config.frameSemantics = .personSegmentationWithDepth
        config.planeDetection = .horizontal
        loadModel(arView: arView)
        arView.session.run(config)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
       
        
    }
    
    
    func loadModel(arView: ARView){
        var cancelable : AnyCancellable?
        cancelable = Entity.loadAsync(named: "fender_stratocaster.usdz").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("无法加载模型,错误：\(error.localizedDescription)")
                }
                cancelable?.cancel()
            }, receiveValue: { entity in
                let planAnchor = AnchorEntity(plane: .horizontal)
                planAnchor.addChild(entity)
                arView.scene.addAnchor(planAnchor)
                
                cancelable?.cancel()
                
            })
    }
    
    
}
