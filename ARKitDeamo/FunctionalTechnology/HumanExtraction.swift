//
//  HumanExtraction.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/2/4.
//

import SwiftUI
import ARKit
import RealityKit
import Combine
import VideoToolbox
import AVFoundation

struct HumanExtraction: View {
    
    var viewModel = HumanExtractionViewModel()
    
    var arView: ARView {
        let arView = ARView(frame: .zero)
        
        return arView
    }
    
    var body: some View {
        HumanExtractionContainer(viewModel: viewModel)
            .overlay(
            VStack{
                Spacer()
                Button(action:{viewModel.catchHuman()}) {
                    Text("截取人形")
                        .frame(width:120,height:40)
                        .font(.body)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .opacity(0.6)
                }
                .offset(y:-30)
                .padding(.bottom, 30)
            }
    )
        .edgesIgnoringSafeArea(.all)
    }
}

struct HumanExtractionContainer : UIViewRepresentable{
   
    var viewModel: HumanExtractionViewModel
    
    
    func makeUIView(context: Context) -> some ARView {
        let arView = ARView(frame: .zero)
        
      
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentation) else {
            return
        }
        
        let config = ARWorldTrackingConfiguration()
        config.frameSemantics = .personSegmentation
        uiView.session.delegate = viewModel
        uiView.session.run(config)
    }
    
    
    
}

class HumanExtractionViewModel: NSObject,ARSessionDelegate {
    var arFrame: ARFrame? = nil
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        arFrame = frame
    }
    func catchHuman(){
        if let segmentationBuffer = arFrame?.segmentationBuffer {
            
            if let uiImage = UIImage(pixelBuffer: segmentationBuffer)?.rotate(radians: .pi / 2) {
                UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(imageSaveHandler(image:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    @objc func imageSaveHandler(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
        if error != nil {
            print("保存图片出错")
        } else {
            print("保存图片成功")
        }
    }
    
}



extension UIImage {
    public convenience init?(pixelBuffer:CVPixelBuffer) {
        var cgimage: CGImage?
        
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgimage)
        
        if let cgimage = cgimage{
            
            self.init(cgImage: cgimage)
            
        }else{
            return nil
        }
    }
    
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            
            draw(in: CGRect(x: -origin.y, y: -origin.x, width: size.width, height: size.height))
            
            let rotateImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotateImage ?? self
            
        }
        
        return self
    }
}
