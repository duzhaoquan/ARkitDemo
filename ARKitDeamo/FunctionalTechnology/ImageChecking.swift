//
//  ImageChecking.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/18.
//

import SwiftUI
import ARKit
import RealityKit

struct ImageChecking: View {
    
    static var arView: ARView?
    
     var body: some View {
         ImageCheckingContainer()
           .overlay(
               VStack{
                   Spacer()
                   HStack(spacing: 50){
                       Button(action: {ImageChecking.arView?.changeObjectsLibrary()}) {
                           Text("切换图像库")
                               
                               .frame(width:150,height:50)
                               .font(.system(size: 17))
                               .foregroundColor(.black)
                               .background(Color.white)
                           
                               .opacity(0.6)
                       }
                       .cornerRadius(10)
                       
                       Button {
                           ImageChecking.arView?.addReferenceImage()
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
    
    
        
    var dele = ARViewImageCheckingDelegate()
    func makeUIView(context: Context) -> some ARView {
        let arView = ARView(frame: .zero)
        
        guard let images = ARReferenceImage.referenceImages(inGroupNamed: "ReferenceImageLibrary", bundle: Bundle.main) else {
            fatalError("无法加载图像")
        }
        let config = ARImageTrackingConfiguration()
        config.trackingImages = images
        config.maximumNumberOfTrackedImages = 1
        config.isAutoFocusEnabled = true//是否自动对焦
        
        arView.session.run(config,options: [])
        arView.session.delegate = dele
        ImageChecking.arView = arView
        return arView
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    
}
extension ARView {
    func changeObjectsLibrary(){
        
        let config = session.configuration as! ARImageTrackingConfiguration
        guard let detectedObjectsLib = ARReferenceImage.referenceImages(inGroupNamed: "ReferenceImageLibrary1", bundle: Bundle.main) else {
            fatalError("无法加载参考物体库")
        }
        config.maximumNumberOfTrackedImages = 1
        config.trackingImages = detectedObjectsLib
        session.run(config, options:[.resetTracking,.removeExistingAnchors])
        print("参考物体库切换成功")
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
class ARViewImageCheckingDelegate: NSObject, ARSessionDelegate {
    
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
               
                ImageChecking.arView?.scene.addAnchor(objectEntity)
            } catch {
                print("加载失败")
            }
                        
        }
        
    }
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
    }
   

}



