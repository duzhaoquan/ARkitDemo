//
//  Audio3DView.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/3/22.
//

import SwiftUI
import ARKit
import RealityKit
import Combine

struct Audio3DView: View {
    var body: some View {
        Audio3DViewContainer().navigationTitle("3D音频").edgesIgnoringSafeArea(.all)
    }
}

struct Audio3DViewContainer:UIViewRepresentable {
    func makeUIView(context: Context) -> some ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        //createPlane(arView: arView)
        
        arView.session.run(config)
        arView.createAudioPlane()
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    static var audioEvent : Cancellable!
    func createPlane(arView:ARView){

        
        let planAnchor = AnchorEntity(plane: .horizontal)
        let boxMesh = MeshResource.generateBox(size: 0.2)
        let boxMaterial = SimpleMaterial(color: .red, isMetallic: true)
        let boxEntity = ModelEntity(mesh: boxMesh, materials: [boxMaterial])
        guard  let audio = try? AudioFileResource.load(named: "fox.mp3",in: .main, inputMode: .spatial,loadingStrategy: .preload,shouldLoop: false) else {
            return
        }
        let audioControler = boxEntity.prepareAudio(audio)
        
        audioControler.play()
        boxEntity.generateCollisionShapes(recursive: false)
        planAnchor.addChild(boxEntity)
        arView.scene.addAnchor(planAnchor)
        arView.installGestures(for: boxEntity)
        Audio3DViewContainer.audioEvent = arView.scene.subscribe(to: AudioEvents.PlaybackCompleted.self) { event in
            print("音频播放完毕")
        }
        
    }
}
var audioEvent : Cancellable!
extension ARView{
    func createAudioPlane(){
        do{
            let planeAnchor = AnchorEntity(plane:.horizontal)
            let boxMesh = MeshResource.generateBox(size: 0.2)
            let boxMaterial = SimpleMaterial(color:.red,isMetallic: true)
            let boxEntity = ModelEntity(mesh:boxMesh,materials:[boxMaterial])
            
            let audio = try AudioFileResource.load(named:"fox.mp3",in:.main,inputMode: .spatial,loadingStrategy: .preload,shouldLoop: false)
            boxEntity.playAudio(audio)
            let audioController = boxEntity.prepareAudio(audio)
            audioController.play()
            boxEntity.generateCollisionShapes(recursive: false)
            planeAnchor.addChild(boxEntity)
            
            self.scene.addAnchor(planeAnchor)
            self.installGestures(.all,for:boxEntity)
            
            audioEvent = self.scene.subscribe(
                to: AudioEvents.PlaybackCompleted.self
            ){ event in
                print("音频播放完毕")
            }
        }
        catch{
            print("Error Loading audio file")
        }
    }
}

#Preview {
    Audio3DView()
}
