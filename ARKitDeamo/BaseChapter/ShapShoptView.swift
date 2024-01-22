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

struct ShapShoptView : View {
    var body: some View {
        return ARViewContainer3()
            .overlay(
                VStack{
                    Spacer()
                    HStack{
                        Button(action:{arView.snapShotAR()}) {
                            Text("AR截图")
                                .frame(width:120,height:40)
                                .font(.body)
                                .foregroundColor(.black)
                                .background(Color.white)
                                .opacity(0.6)
                        }
                        .offset(y:-30)
                        .padding(.bottom, 30)
                        Button(action: {arView.snapShotCamera()}) {
                            Text("摄像机截图")
                                .frame(width:120,height:40)
                                .font(.body)
                                .foregroundColor(.black)
                                .background(Color.white)
                                .opacity(0.6)
                        }
                        .offset(y:-30)
                        .padding(.bottom, 30)
                    }
                }
            )
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("AR截屏")
    }
}
var arView : ARView!

struct ARViewContainer3: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options:[ ])
        arView.session.delegate = arView
        arView.createPlane3()
        return arView
    }
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

extension ARView {
    func createPlane3(){
        let planeAnchor = AnchorEntity(plane:.horizontal)
        do {
            let cubeMesh = MeshResource.generateBox(size: 0.2)
            var cubeMaterial = SimpleMaterial(color:.white,isMetallic: false)
            cubeMaterial.color = try SimpleMaterial.BaseColor(tint:UIColor.yellow.withAlphaComponent(0.9999), texture: MaterialParameters.Texture(TextureResource.load(named: "Box_Texture.jpg")))
            let cubeEntity = ModelEntity(mesh:cubeMesh,materials:[cubeMaterial])
            cubeEntity.generateCollisionShapes(recursive: false)
            planeAnchor.addChild(cubeEntity)
            self.scene.addAnchor(planeAnchor)
            self.installGestures(.all,for:cubeEntity)
        } catch {
            print("找不到文件")
        }
    }
    
    func snapShotAR(){
        //方法一
         arView.snapshot(saveToHDR: false){(image) in
             UIImageWriteToSavedPhotosAlbum(image!, self, #selector(self.imageSaveHandler(image:didFinishSavingWithError:contextInfo:)), nil)
         }
        //方法二
        /*
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let uiImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(uiImage!, self, #selector(imageSaveHandler(image:didFinishSavingWithError:contextInfo:)), nil)
        */
    }

    func snapShotCamera(){
        guard let pixelBuffer = arView.session.currentFrame?.capturedImage else {
            return
        }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer),
        context = CIContext(options: nil),
        cgImage = context.createCGImage(ciImage, from: ciImage.extent),
        uiImage = UIImage(cgImage: cgImage!, scale: 1, orientation: .right)
        UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(imageSaveHandler(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func imageSaveHandler(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil {
            print("保存图片出错")
        } else {
            print("保存图片成功")
        }
    }
}

