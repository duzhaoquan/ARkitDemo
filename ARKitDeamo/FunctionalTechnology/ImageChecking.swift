//
//  ImageChecking.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/18.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

struct ImageChecking: View {
    
    @State  var changeImage = false
    @State  var addImage = false
    
     var body: some View {
         ImageCheckingContainer(changeImage: $changeImage, addImage: $addImage)
           .overlay(
               VStack{
                   Spacer()
                   HStack(spacing: 50){
                       Button(action: {
                           changeImage = true
                           addImage = false
                       }) {
                           Text("切换图像库")
                               
                               .frame(width:150,height:50)
                               .font(.system(size: 17))
                               .foregroundColor(.black)
                               .background(Color.white)
                           
                               .opacity(0.6)
                       }
                       .cornerRadius(10)
                       
                       Button {
                           addImage = true
                           changeImage = false
                       } label: {
                           Text("添加图像")
                               .frame(width: 150, height: 50)
                               .font(.system(size: 17))
                               .foregroundColor(.black)
                               .background(Color.white)
                               .opacity(0.6)
                       }
                       .cornerRadius(10)

                   }
                   Spacer().frame(height: 40)
               }
       )
           .edgesIgnoringSafeArea(.all)
           .navigationTitle("图像检测")
    }
    
}
struct ImageCheckingContainer: UIViewRepresentable {
    
    @Binding  var changeImage:Bool
    @Binding  var addImage:Bool
    func makeUIView(context: Context) ->  ARView {
        let arView = ARView(frame: .zero)
        return arView
    }
    func updateUIView(_ uiView: ARView, context: Context) {
        
        if changeImage {
            let config = uiView.session.configuration as! ARImageTrackingConfiguration
            guard let detectedObjectsLib = ARReferenceImage.referenceImages(inGroupNamed: "ReferenceImageLibrary1", bundle: Bundle.main) else {
                fatalError("无法加载参考物图像")
            }
            config.maximumNumberOfTrackedImages = 1
            config.trackingImages = detectedObjectsLib
            uiView.session.run(config, options:[.resetTracking,.removeExistingAnchors])
            print("参考图像库切换成功")
            return
        }
        
        if addImage {
            guard let config = uiView.session.configuration as? ARImageTrackingConfiguration else {return}
            guard let image = UIImage(named:"toy_biplane")?.cgImage else { return }
            let referenceImage = ARReferenceImage(image,orientation: .up, physicalWidth: 0.15)
            config.trackingImages.insert(referenceImage)
            uiView.session.run(config, options: [])
            print("insert image OK")
            return
        }
        
        guard let images = ARReferenceImage.referenceImages(inGroupNamed: "ReferenceImageLibrary", bundle: Bundle.main) else {
            fatalError("无法加载图像")
        }
        let config = ARImageTrackingConfiguration()
        config.trackingImages = images
        config.maximumNumberOfTrackedImages = 1
        config.isAutoFocusEnabled = true//是否自动对焦
        
        context.coordinator.arView = uiView
        uiView.session.run(config,options: [])
        uiView.session.delegate = context.coordinator
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject,ARSessionDelegate{
        var parent: ImageCheckingContainer
        var arView: ARView? = nil
        init(_ parent: ImageCheckingContainer) {
            self.parent = parent
        }
        public func session(_ session: ARSession, didAdd anchors: [ARAnchor]){
           guard let pAnchor = anchors[0] as? ARImageAnchor else {
              return
            }
            

            let objectName =  pAnchor.referenceImage.name == "toy_drummer" ? "toy_drummer" : "toy_robot_vintage"
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
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            
        }
    }
    
}
extension ARView {
    func changeImagesLibrary(){
        
        let config = session.configuration as! ARImageTrackingConfiguration
        guard let detectedObjectsLib = ARReferenceImage.referenceImages(inGroupNamed: "ReferenceImageLibrary1", bundle: Bundle.main) else {
            fatalError("无法加载参考物图像")
        }
        config.maximumNumberOfTrackedImages = 1
        config.trackingImages = detectedObjectsLib
        session.run(config, options:[.resetTracking,.removeExistingAnchors])
        print("参考图像库切换成功")
    }
    func addReferenceImage(){
      
        guard let config = session.configuration as? ARImageTrackingConfiguration else {return}
        guard let image = UIImage(named:"toy_biplane")?.cgImage else { return }
        let referenceImage = ARReferenceImage(image,orientation: .up, physicalWidth: 0.15)
        config.trackingImages.insert(referenceImage)
        session.run(config, options: [])
        print("insert image OK")
    }
}


