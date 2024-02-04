//
//  BodyTrackingView.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/2/1.
//

import SwiftUI
import ARKit
import RealityKit


struct BodyTrackingView: View {
    var body: some View {
        BodyTrackingViewContainer().edgesIgnoringSafeArea(.all).navigationTitle("人体骨架2D检测")
    }
}

struct BodyTrackingViewContainer:UIViewRepresentable {
   
    
    
    func makeUIView(context: Context) ->ARView {
        let arView = ARView(frame: .zero)
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        guard ARBodyTrackingConfiguration.isSupported else {
            return
        }
        
        context.coordinator.arView = uiView
        let config = ARBodyTrackingConfiguration()
        
        config.frameSemantics = .bodyDetection
        config.automaticSkeletonScaleEstimationEnabled = true
        
        uiView.session.delegate = context.coordinator
        
        uiView.session.run(config)
        
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject,ARSessionDelegate {
        var arView : ARView? = nil
        let circleWidth: CGFloat = 10
        let circleHeight: CGFloat = 10
        var isPrinted = false
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard let arView = arView else {
                return
            }
            //清除骨骼圆圈
            arView.layer.sublayers?.compactMap({
                $0 as? CAShapeLayer
            }).forEach({
                $0.removeFromSuperlayer()
            })
            guard let detectedBody =  frame.detectedBody else {
                return
            }
            
            guard let orientation = arView.window?.windowScene?.interfaceOrientation else {
                return
            }
            let transform = frame.displayTransform(for: orientation, viewportSize: arView.frame.size)
            
            detectedBody.skeleton.jointLandmarks.forEach { landmark in
                let normalizeCenter = CGPoint(x: CGFloat(landmark.x), y: CGFloat(landmark.y)).applying(transform)
                let center = normalizeCenter.applying(.identity.scaledBy(x: arView.frame.width, y: arView.frame.height))
                
                let rect = CGRect(x: center.x - circleWidth/2, y: center.y - circleWidth/2, width: circleWidth, height: circleHeight)
                
                let circleLayer = CAShapeLayer()
                
                circleLayer.path = UIBezierPath(ovalIn: rect).cgPath
                
                arView.layer.addSublayer(circleLayer)
                
            }
            
            if !isPrinted {
                let jointNames = detectedBody.skeleton.definition.jointNames
                for name in jointNames {
                    let landmark = detectedBody.skeleton.landmark(for: ARSkeleton.JointName(rawValue: name))
                    let index = detectedBody.skeleton.definition.index(for: ARSkeleton.JointName(rawValue: name))
                    
                    print("\(name),\(String(describing: landmark)),the index is \(index) parent index is  \(detectedBody.skeleton.definition.parentIndices[index])")
                }
                print("last: \(ARSkeleton2D.JointName.rightShoulder.rawValue)")
                isPrinted = true
            }
            
            
        }
        
    }
    
    
    
    
}

