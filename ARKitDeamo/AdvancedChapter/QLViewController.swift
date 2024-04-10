import UIKit
import QuickLook
import ARKit

class QLViewController: UIViewController, QLPreviewControllerDataSource {

    override func viewDidAppear(_ animated: Bool) {
        let previewController = QLPreviewController()
        
        previewController.dataSource = self
        present(previewController, animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.popViewController(animated: animated)
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let filePath = Bundle.main.url(forResource: "fender_stratocaster", withExtension: "usdz") else {fatalError("无法加载模型")}
        let item = ARQuickLookPreviewItem(fileAt: filePath)
        item.allowsContentScaling = true
        item.canonicalWebPageURL = URL(string: "https://www.example.com/example.usdz")
        return item
    }
}
