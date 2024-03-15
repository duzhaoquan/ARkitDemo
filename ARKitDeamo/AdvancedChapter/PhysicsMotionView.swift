//
//  PhysicsMotionView.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/3/14.
//

import SwiftUI
import RealityKit
import ARKit

struct PhysicsMotionView: View {
    var body: some View {
        PhysicsMotionViewContainer().navigationTitle("物理模拟2").edgesIgnoringSafeArea(.all)
    }
}

struct PhysicsMotionViewContainer:UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    
    
    func makeUIView(context: Context) -> some ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        
        context.coordinator.arView = arView
        context.coordinator.loadModel()
        arView.session.delegate  = context.coordinator
        arView.session.run(config)
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    
    class Coordinator: NSObject, ARSessionDelegate{
        var sphereEntity : ModelEntity!
        var arView:ARView? = nil
        let gameController = GameController()
        
        @MainActor func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let anchor = anchors.first as? ARPlaneAnchor,
                  
                  let arView = arView else{
                return
            }
            let planeAnchor = AnchorEntity(anchor:anchor)
            
            
            
            planeAnchor.addChild(gameController.gameAnchor)
            arView.scene.anchors.append(planeAnchor)
            gameController.gameAnchor.backWall?.visit { entity in
                entity.components[ModelComponent.self] = nil
            }
            gameController.gameAnchor.frontWall?.visit { entity in
                entity.components[ModelComponent.self] = nil
            }
            gameController.Ball13?.physicsBody?.massProperties.centerOfMass = ([0.001,0,0.001],simd_quatf(angle: 0, axis:  [0,1,0]))
            gameController.Ball4?.physicsBody?.material = PhysicsMaterialResource.generate(friction: 0.3, restitution: 0.3)
            gameController.Ball6?.physicsBody?.mode = .kinematic
            //gameController.Ball6?.collision?.shapes.removeAll()
            arView.session.delegate = nil
            arView.session.run(ARWorldTrackingConfiguration())
        }
        @MainActor func loadModel(){
            gameController.gameAnchor = try! Ball.loadBallGame()
            if let ball = gameController.gameAnchor.motherBall as? Entity & HasCollision {
                let gestureRecognizers = arView?.installGestures(.translation, for: ball)
                if let gestureRecognizer = gestureRecognizers?.first as? EntityTranslationGestureRecognizer {
                    gameController.gestureRecognizer = gestureRecognizer
                    gestureRecognizer.removeTarget(nil, action: nil)
                    gestureRecognizer.addTarget(self, action: #selector(self.handleTranslation))
                }
            }
        }
       @objc
       func handleTranslation(_ recognizer: EntityTranslationGestureRecognizer) {
           guard let ball = gameController.motherBall else { return }
           let settings = gameController.settings
           if recognizer.state == .ended || recognizer.state == .cancelled {
               gameController.gestureStartLocation = nil
               ball.physicsBody?.mode = .dynamic
               return
           }
           guard let gestureCurrentLocation = recognizer.translation(in: nil) else { return }
           guard let gestureStartLocation = gameController.gestureStartLocation else {
               gameController.gestureStartLocation = gestureCurrentLocation
               return
           }
           let delta = gestureStartLocation - gestureCurrentLocation
           let distance = ((delta.x * delta.x) + (delta.y * delta.y) + (delta.z * delta.z)).squareRoot()
           if distance > settings.ballPlayDistanceThreshold {
               gameController.gestureStartLocation = nil
               ball.physicsBody?.mode = .dynamic
               return
           }
           ball.physicsBody?.mode = .kinematic
           let realVelocity = recognizer.velocity(in: nil)
           let ballParentVelocity = ball.parent!.convert(direction: realVelocity, from: nil)
           var clampedX = ballParentVelocity.x
           var clampedZ = ballParentVelocity.z
           // 夹断
           if clampedX > settings.ballVelocityMaxX {
               clampedX = settings.ballVelocityMaxX
           } else if clampedX < settings.ballVelocityMinX {
               clampedX = settings.ballVelocityMinX
           }
           // 夹断
           if clampedZ > settings.ballVelocityMaxZ {
               clampedZ = settings.ballVelocityMaxZ
           } else if clampedZ < settings.ballVelocityMinZ {
               clampedZ = settings.ballVelocityMinZ
           }
           
           let clampedVelocity: SIMD3<Float> = [clampedX, 0.0, clampedZ]
           ball.physicsMotion?.linearVelocity = clampedVelocity
       }
    }
}
extension Entity {
    func visit(using block: (Entity) -> Void) {
        block(self)
        for child in children {
            child.visit(using: block)
        }
    }
}
#Preview {
    PhysicsMotionView()
}
