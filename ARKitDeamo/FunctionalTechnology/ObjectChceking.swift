//
//  ObjectChceking.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/22.
//

import SwiftUI
import ARKit
import RealityKit

struct ObjectChceking: View {
    
    @State var changeObject = false
    
     var body: some View {
         ObjectChcekingContainer(changeObject: changeObject)
           .overlay(
               VStack{
                   Spacer()
                   Button(action: {changeObject.toggle()}) {
                       Text("切换物体库")
                           .frame(width:150,height:50)
                           .font(.system(size: 17))
                           .foregroundColor(.black)
                           .background(Color.white)
                       
                           .opacity(0.6)
                   }
                   .cornerRadius(10)
                   Spacer().frame(height: 40)
               }
       )
           .edgesIgnoringSafeArea(.all)
           .navigationTitle("3D物体检测")
    }
    
}
struct ObjectChcekingContainer: UIViewRepresentable {
    
    var changeObject = false
    func makeUIView(context: Context) -> some ARView {
        let arView = ARView(frame: .zero)
        return arView
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if changeObject {
            guard let config = uiView.session.configuration as? ARWorldTrackingConfiguration else {
                return
            }
            guard let detectedObjectsLib = ARReferenceObject.referenceObjects(inGroupNamed: "ReferenceObjectsLibrary1", bundle: Bundle.main) else {
                fatalError("无法加载参考物体库")
            }
            config.maximumNumberOfTrackedImages = 1
            config.detectionObjects = detectedObjectsLib
            uiView.session.run(config, options:[.resetTracking,.removeExistingAnchors])
            print("参考物体库切换成功")
            
            return
        }
        guard let images = ARReferenceObject.referenceObjects(inGroupNamed: "ReferenceObjectsLibrary", bundle: Bundle.main) else {
            fatalError("无法加载物体")
        }
        print("参考物体库加载成功")
        let config = ARWorldTrackingConfiguration()
        config.detectionObjects = images
        
        uiView.session.run(config,options: [])
        context.coordinator.arView = uiView
        uiView.session.delegate = context.coordinator
    }
    
    func makeCoordinator() -> ObjectChcekingCoordinator {
        ObjectChcekingCoordinator(self)
    }
    
    class ObjectChcekingCoordinator: NSObject, ARSessionDelegate {
        var parent: ObjectChcekingContainer
        var arView: ARView? = nil
        init(_ parent: ObjectChcekingContainer) {
            self.parent = parent
        }
        public func session(_ session: ARSession, didAdd anchors: [ARAnchor]){
           guard let pAnchor = anchors[0] as? ARObjectAnchor else {
              return
            }
            

            let objectName =  pAnchor.referenceObject.name == "jinhua" ? "toy_drummer" : "toy_robot_vintage"
            DispatchQueue.main.async {
                do{
                    let myModeEntity = try Entity.load(named: objectName)
                    let objectEntity = AnchorEntity(anchor: pAnchor)
                    objectEntity.addChild(myModeEntity)
                    myModeEntity.playAnimation(myModeEntity.availableAnimations[0].repeat())
                   
                    self.arView?.scene.addAnchor(objectEntity)
                } catch {
                    print("加载失败")
                }
                            
            }
            
        }
    }
    
}
extension ARView {
    func changeObjectsLibrary(){
        
        guard let config = session.configuration as? ARWorldTrackingConfiguration else {
            return
        }
        guard let detectedObjectsLib = ARReferenceObject.referenceObjects(inGroupNamed: "ReferenceObjectsLibrary1", bundle: Bundle.main) else {
            fatalError("无法加载参考物体库")
        }
        config.maximumNumberOfTrackedImages = 1
        config.detectionObjects = detectedObjectsLib
        session.run(config, options:[.resetTracking,.removeExistingAnchors])
        print("参考物体库切换成功")
    }
    
}

