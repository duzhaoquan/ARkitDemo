//
//  ARQuickLookView.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/4/10.
//

import SwiftUI
import QuickLook
import ARKit

struct ARQuickLookViewController: UIViewControllerRepresentable {
    var fileName: String
    var allowScaling: Bool
    func makeCoordinator() -> ARQuickLookViewController.Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        
        return controller
    }
    
    func updateUIViewController(_ controller: UIViewController,context: Context) {}
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: ARQuickLookViewController
        private lazy var fileURL: URL = Bundle.main.url(forResource: parent.fileName,withExtension: "usdz")!
        init(_ parent: ARQuickLookViewController) {
            self.parent = parent
            super.init()
        }
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
        func previewController(_ controller: QLPreviewController,previewItemAt index: Int) -> QLPreviewItem {
            guard let filePath = Bundle.main.url(forResource: parent.fileName, withExtension: "usdz") else {fatalError("无法加载模型")}
            let item = ARQuickLookPreviewItem(fileAt: filePath)
            item.allowsContentScaling = parent.allowScaling
            
            item.canonicalWebPageURL = URL(string: "https://www.example.com/example.usdz")
            return item
        }
    }
}


struct ARQuickLookView : View {
    @State var showingPreview = false
    var body: some View {

        ARQuickLookViewController(fileName: "fender_stratocaster",allowScaling:true)
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("AR Quick Look")
    }
}
