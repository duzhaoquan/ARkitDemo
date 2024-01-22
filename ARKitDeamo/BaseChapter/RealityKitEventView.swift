//
//  ContentView.swift
//  Chapter1
//
//  Created by Davidwang on 2020/4/17.
//  Copyright © 2020 Davidwang. All rights reserved.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct RealityKitEventView : View {
    var body: some View {
        return ARViewContainer8().edgesIgnoringSafeArea(.all).navigationTitle("AR事件系统")
    }
}

struct ARViewContainer8: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options: [])
        arView.setupGestures()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

extension ARView{
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let touchInView = sender?.location(in: self) else {
            return
        }
        guard let raycastQuery = self.makeRaycastQuery(from: touchInView, allowing: .existingPlaneInfinite,alignment: .horizontal) else {
            return
        }
        guard let result = self.session.raycast(raycastQuery).first else {return}
        let transformation = Transform(matrix: result.worldTransform)
        let box = CustomEntity(color: .yellow,position: transformation.translation)
        self.installGestures(.all, for: box)
        box.addCollisions(scene: self)
        self.scene.addAnchor(box)
    }
}
//自定义实体类
class CustomEntity: Entity, HasModel, HasAnchoring, HasCollision {
    var subscribes: [Cancellable] = []
    required init(color: UIColor) {git
        super.init()
        //设置碰撞组件，可以和其他实体发生碰撞
        self.components.set(CollisionComponent(
            shapes: [.generateBox(size: [0.1,0.1,0.1])],
            mode: .default,
            filter: CollisionFilter(group: CollisionGroup(rawValue: 1), mask: CollisionGroup(rawValue: 1))
        ))
        
        //添加组件，定义实体的模型资源
        self.components.set( ModelComponent(
            mesh: .generateBox(size: [0.1,0.1,0.1]),
            materials: [SimpleMaterial(color: color,isMetallic: false)]
        ))
    }
    
    convenience init(color: UIColor, position: SIMD3<Float>) {
        self.init(color: color)
        self.position = position
    }
    
    required init() {
        fatalError("init()没有执行，初始化不成功")
    }
    
    func addCollisions(scene: ARView) {
        subscribes.append(scene.scene.subscribe(to: CollisionEvents.Began.self, on: self) { event in
            guard let box = event.entityA as? CustomEntity else {
                return
            }
            //发生碰撞时把实体变成红色
            box.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
            
        })
        subscribes.append(scene.scene.subscribe(to: CollisionEvents.Ended.self, on: self) { event in
            guard let box = event.entityA as? CustomEntity else {
                return
            }
            box.model?.materials = [SimpleMaterial(color: .yellow, isMetallic: false)]
        })
    }
}
