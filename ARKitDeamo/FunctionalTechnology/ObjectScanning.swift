//
//  ObjectScanning.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/23.
//



import ARKit
import SwiftUI
import RealityKit

struct ObjectScanningView: UIViewRepresentable {
    @Binding var isScanning: Bool
    @Binding var scanPrompt: String
    func makeUIView(context: Context) -> ARView {
        let arView = ARView()
        arView.session.delegate = context.coordinator
        return arView
    }
   
    func updateUIView(_ uiView: ARView, context: Context) {
        if isScanning {
            // 开始扫描
            let configuration = ARObjectScanningConfiguration()
            uiView.session.run(configuration, options: [])
        } else {
            // 停止扫描
            uiView.session.pause()
        }
    }
    func showScanPrompt(_ mappingStatus: ARFrame.WorldMappingStatus) -> String {
        // 根据不同的扫描状态显示不同的提示
        var promptText = ""
        switch mappingStatus {
        case .notAvailable:
            promptText = "无法进行扫描，尝试改善光照条件。"
        case .limited:
            promptText = "扫描受限，调整位置或尝试增加纹理。"
        case .extending:
            promptText = "扫描正在进行，尝试保持相机在扫描区域内。"
        case .mapped:
            promptText = "扫描成功！你可以添加更多物体或停止扫描。"
        @unknown default:
            promptText = "扫描状态未知。"
        }
        print("Scan Prompt: \(promptText)")
        return promptText
        // 在此处将提示文本显示给用户，例如通过弹出消息或在界面上显示
        
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ObjectScanningView

        init(_ parent: ObjectScanningView) {
            self.parent = parent
        }

        // 实现 ARSessionDelegate 中的方法
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // 处理扫描后的帧更新
            DispatchQueue.main.async {
                // 在界面上显示扫描提示
                self.parent.scanPrompt = self.parent.showScanPrompt(frame.worldMappingStatus)
            }
        }

        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            // 处理识别到的物体锚点
            if let anchor = anchors.first as? ARObjectAnchor {
                // 在此处理识别到的物体锚点信息，你可以保存锚点的信息到本地
                saveObjectAnchorInfo(anchor)
            }
        }
        func session(_ session: ARSession, didFailWithError error: Error) {
            print("AR Session Failed: \(error.localizedDescription)")
        }

        func saveObjectAnchorInfo(_ anchor: ARObjectAnchor) {
            // 保存锚点信息到本地文件或云存储
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
//                let fileURL =  // 设置保存文件的路径
//                try data.write(to: fileURL)
                print("保存 ARObjectAnchor 成功")
            } catch {
                print("保存 ARObjectAnchor 失败: \(error.localizedDescription)")
            }
        }
    }
}

struct ObjectScanning: View {
    @State private var isScanning = false
    @State private var scanPrompt:String = ""

    var body: some View {
        VStack {
            ObjectScanningView(isScanning: $isScanning, scanPrompt: $scanPrompt)
                .overlay(
                    VStack{
                        Spacer()
                        // 添加其他 UI 元素，例如按钮控制扫描状态
                        Text("扫描提示: \(scanPrompt)")
                            .padding()
                            .foregroundColor(.black)
                            .background(Color.yellow)
                            .cornerRadius(10)
                        Button(action: {
                            isScanning.toggle()
                        }) {
                            Text(isScanning ? "Stop Scanning" : "Start Scanning")
                                .padding()
                                .frame(width:150,height:50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
        
                        Spacer().frame(height: 40)
                    }
                )
                .edgesIgnoringSafeArea(.all)
                .navigationTitle("3D物体检测")
                .onAppear {
                    // 在视图出现时开始扫描
                    isScanning = true
                }
                .onDisappear {
                    // 在视图消失时停止扫描
                    isScanning = false
                }
            
            
        }
    }
}
