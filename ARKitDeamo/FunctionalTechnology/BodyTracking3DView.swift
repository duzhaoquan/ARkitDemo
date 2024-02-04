//
//  BodyTracking3DView.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/2/1.
//

import SwiftUI

import SwiftUI
import ARKit
import RealityKit
import Combine


struct BodyTracking3DView: View {
    @State var showRobot3D = false
    var body: some View {
        BodyTracking3DViewContainer(showRobot3D: $showRobot3D)
            .overlay(content: {
               
                VStack {
                    Spacer()
                    HStack{
                        Text(showRobot3D ? "展示3D模型" : "展示眼睛小球")
                            .background(GeometryReader{ _ in
                                Color.white
                            })
                            .padding(10)
                            .offset(x: 0)
                        Toggle(isOn: $showRobot3D) {}
                            .frame(width: 50)
                            .offset(x: 0)
                    }
                    
                    Spacer().frame(height: 40)
                }
                

            })
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("人体骨架3D检测")
    }
}

struct BodyTracking3DViewContainer:UIViewRepresentable {
    @Binding var showRobot3D: Bool
    
    
    func makeUIView(context: Context) ->ARView {
        let arView = ARView(frame: .zero)
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        guard ARBodyTrackingConfiguration.isSupported else {
            return
        }
        let _  = showRobot3D
        context.coordinator.arView = uiView
        let config = ARBodyTrackingConfiguration()
        
        config.frameSemantics = .bodyDetection
        config.automaticSkeletonScaleEstimationEnabled = true
        
        uiView.session.delegate = context.coordinator
        
        uiView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject,ARSessionDelegate {
        var parent:BodyTracking3DViewContainer
        init(parent: BodyTracking3DViewContainer) {
            self.parent = parent
        }
        
        
        var arView : ARView? = nil
        var isPrinted = false
        
        //添加眼睛小球
        var eyeAnchor = AnchorEntity()
        var leftEye: ModelEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.02), materials: [SimpleMaterial(color: .blue, isMetallic: false)])
        var rightEye: ModelEntity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.02), materials: [SimpleMaterial(color: .blue, isMetallic: false)])
        func createSphere (){
            
            eyeAnchor.addChild(leftEye)
            eyeAnchor.addChild(rightEye)
            
            arView?.scene.addAnchor(eyeAnchor)
            
            
        }
        
        var robotCharacter: BodyTrackedEntity?
        let robotOffset: SIMD3<Float> = [-0.1, 0, 0]
        let robotAnchor = AnchorEntity()
        func loadRobot(){
            var cancellable: AnyCancellable? = nil
            cancellable = Entity.loadBodyTrackedAsync(named: "robot.usdz").sink { completion in
                if case let .failure(error) = completion {
                    print("无法加载模型,错误：\(error.localizedDescription)")
                }
                cancellable?.cancel()
            } receiveValue: { body in
                body.scale = [1.0,1.0,1.0]
                
                self.robotCharacter = body
                self.arView?.scene.addAnchor(self.robotAnchor)
                cancellable?.cancel()
            }

        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            guard let anchor = anchors.first as? ARBodyAnchor else {
                return
            }
            if parent.showRobot3D {
                arView?.scene.removeAnchor(eyeAnchor)
                loadRobot()
                
            }else{
                arView?.scene.removeAnchor(robotAnchor)
                createSphere()
                
            }
            
            
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let anchor = anchors.first as? ARBodyAnchor else {
                return
            }
            
            let bodyPosition = simd_make_float3(anchor.transform.columns.3) //位置平移信息
            robotAnchor.position = bodyPosition + robotOffset
            robotAnchor.orientation = Transform(matrix: anchor.transform).rotation
            
            if let robotCharacter = robotCharacter,robotCharacter.parent == nil {
                robotAnchor.addChild(robotCharacter)
            }
            
            //更新眼睛小球位置，
            guard let leftMatrix = anchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "left_eye_joint")),
                  let rightMatrix = anchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: "right_eye_joint")) else {
                return
            }
            
            leftEye.position = simd_make_float3(  leftMatrix.columns.3)
            rightEye.position = simd_make_float3(rightMatrix.columns.3)
            //跟节点的位置付值给anchor
            eyeAnchor.position = simd_make_float3(anchor.transform.columns.3)
            
            if !isPrinted {
                isPrinted = true
                
                //获取root节点在世界坐标系中的姿态
                let hipWordPosition = anchor.transform
                print("root transform: \(hipWordPosition)")
                //获取3d骨骼对象
                let skeleton = anchor.skeleton
                //获取相对于root节点所有节点的姿态信息数组
                let jointTranforms = skeleton.jointModelTransforms
                //获取在世界空间坐标系中所有节点的姿态信息数组
                let localTransform = skeleton.jointLocalTransforms
                //遍历姿态信息数字，通过下标遍历
                for (i, jointTransform) in jointTranforms.enumerated() {
                      
                    
                    let name = anchor.skeleton.definition.jointNames[i]
                    let parentIndex = skeleton.definition.parentIndices[i]
                    
                    guard parentIndex != -1 else {
                        continue
                    }
                    let parentJointTransform = jointTranforms[parentIndex]
                    let parentName = anchor.skeleton.definition.jointNames[parentIndex]
                    
                    
                    print("name: \(name),index: \(i), transform: \(String(describing: jointTransform)), parent name: \(parentName),parent index: \(parentIndex) parent transform: \(String(describing: parentJointTransform))")
                    
                }
                
                //通过名字遍历
                let jointNames = anchor.skeleton.definition.jointNames
                for name in jointNames {
                    let landmark = anchor.skeleton.modelTransform(for: ARSkeleton.JointName(rawValue: name))
                    let index = anchor.skeleton.definition.index(for: ARSkeleton.JointName(rawValue: name))
                    
                    print("\(name),\(String(describing: landmark)),the index is \(index) parent index is  \(anchor.skeleton.definition.parentIndices[index])")
                }
                
                
                
            }
            
        }
        
        
    }
    
    
    
}
