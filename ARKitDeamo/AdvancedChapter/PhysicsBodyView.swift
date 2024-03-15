//
//  PhysicsBodyView.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/3/14.
//

import SwiftUI
import ARKit
import RealityKit

struct PhysicsBodyView: View {
    var body: some View {
        PhysicsBodyViewContainer().navigationTitle("物理模拟").edgesIgnoringSafeArea(.all)
    }
}
struct PhysicsBodyViewContainer:UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    
    
    func makeUIView(context: Context) -> some ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        
        context.coordinator.arView = arView
        
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
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let anchor = anchors.first as? ARPlaneAnchor,
                  let arView = arView else{
                return
            }
            let planeAnchor = AnchorEntity(anchor:anchor)
            
            //sample1
            let boxCollider: ShapeResource = .generateBox(size: [0.1,0.2,1])
            let box: MeshResource = .generateBox(size: [0.1,0.2,1], cornerRadius: 0.02)
            let boxMaterial = SimpleMaterial(color: .yellow,isMetallic: true)
            let boxEntity = ModelEntity(mesh: box, materials: [boxMaterial], collisionShape: boxCollider, mass: 0.05)
            boxEntity.physicsBody?.mode = .dynamic
            boxEntity.name = "Box"
            boxEntity.transform.translation = [0.2,planeAnchor.transform.translation.y+0.15,0]
            
            let sphereCollider : ShapeResource = .generateSphere(radius: 0.05)
            let sphere: MeshResource = .generateSphere(radius: 0.05)
            let sphereMaterial = SimpleMaterial(color:.red,isMetallic: true)
            sphereEntity = ModelEntity(mesh: sphere, materials: [sphereMaterial], collisionShape: sphereCollider, mass: 0.04)
            sphereEntity.physicsBody?.mode = .dynamic
            sphereEntity.name = "Sphere"
            sphereEntity.transform.translation = [-0.3,planeAnchor.transform.translation.y+0.15,0]
            sphereEntity.physicsBody?.material = .generate(friction: 0.001, restitution: 0.01)
            //平面
            let plane :MeshResource = .generatePlane(width: 1.2, depth: 1.2)
            let planeCollider : ShapeResource = .generateBox(width: 1.2, height: 0.01, depth: 1.2)
            let planeMaterial = SimpleMaterial(color:.gray,isMetallic: false)
            let planeEntity = ModelEntity(mesh: plane, materials: [planeMaterial], collisionShape: planeCollider, mass: 0.01)
            planeEntity.physicsBody?.mode = .static//静态平面不具备碰撞性
            planeEntity.physicsBody?.material = .generate(friction: 0.001, restitution: 0.1)
            
            planeAnchor.addChild(planeEntity)
            planeAnchor.addChild(boxEntity)
            planeAnchor.addChild(sphereEntity)
            
            //添加碰撞订阅
            let subscription = arView.scene.subscribe(to: CollisionEvents.Began.self, { event in
                print("box发生碰撞")
                print("entityA.name: \(event.entityA.name)")
                print("entityB.name: \(event.entityB.name)")
                print("Force : \(event.impulse)")
                print("Collision Position: \(event.position)")
            })
            gameController.collisionEventStreams.append(subscription)
            
            arView.scene.addAnchor(planeAnchor)
            let gestureRecognizers = arView.installGestures(.translation, for: sphereEntity)
            if let gestureRecognizer = gestureRecognizers.first as? EntityTranslationGestureRecognizer {
                gameController.gestureRecognizer = gestureRecognizer
                gestureRecognizer.removeTarget(nil, action: nil)
                gestureRecognizer.addTarget(self, action: #selector(handleTranslation))
            }
            arView.session.delegate = nil
            arView.session.run(ARWorldTrackingConfiguration())
        }
        @objc func handleTranslation(_ recognizer: EntityTranslationGestureRecognizer){
            guard let ball = sphereEntity else { return }
        
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
            //ball.physicsBody?.mode = .kinematic
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
            //ball.physicsMotion?.linearVelocity = clampedVelocity
         
            ball.addForce(clampedVelocity*0.1, relativeTo: nil)
        }
    }
}

#Preview {
    PhysicsBodyView()
}
