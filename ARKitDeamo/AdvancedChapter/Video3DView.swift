//
//  Video3DView.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/3/26.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

struct Video3DView: View {
    static var arView:ARView!
    var body: some View {
        Video3DViewContainer().overlay(
            VStack{
                Spacer()
                HStack{
                    Button(action:{Video3DView.arView.playOrPause()}) {
                        Text("播放/暂停")
                            .frame(width:120,height:40)
                            .font(.body)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .opacity(0.6)
                    }
                    .offset(y:-30)
                    .padding(.bottom, 30)
                    Button(action: {Video3DView.arView.reset()}) {
                        Text("重播")
                            .frame(width:120,height:40)
                            .font(.body)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .opacity(0.6)
                    }
                    .offset(y:-30)
                    .padding(.bottom, 30)
                }
                Spacer().frame(height: 40)
            }
    ).navigationTitle("3D视频").edgesIgnoringSafeArea(.all)
    }
}
var videoPlayController : VideoPlayController!
struct Video3DViewContainer:UIViewRepresentable {
    
    func makeUIView(context: Context) -> some ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        Video3DView.arView = arView
        
        arView.session.run(config)
        arView.createVideoPlane()
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
   
}

var play = false;
extension ARView{
    func createVideoPlane(isLoop: Bool = false){
        videoPlayController  = VideoPlayController("video2", withExtension: "mp4", useLooper:false)
        guard let vPlayController = videoPlayController,
              let planeMaterial = videoPlayController.material else {return}
        let planeAnchor = AnchorEntity(plane:.horizontal)
        let boxMesh = MeshResource.generatePlane(width: 0.2, height: 0.4, cornerRadius: 0)
        let boxEntity = ModelEntity(mesh: boxMesh,materials: [planeMaterial])
        boxEntity.generateCollisionShapes(recursive: false)
        planeAnchor.addChild(boxEntity)
        self.scene.addAnchor(planeAnchor)
        self.installGestures(.all,for:boxEntity)
    }
    func playOrPause(){
        play = !play
        videoPlayController.enablePlayPause(play)
    }
    func reset(){
        videoPlayController.reset()
        videoPlayController.enablePlayPause(true)
    }
    

    
}


