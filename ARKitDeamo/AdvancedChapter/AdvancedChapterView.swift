//
//  AdvancedChapterView.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/2/20.
//

import SwiftUI

struct AdvancedChapterView: View {
    @EnvironmentObject var tabbar: TabBarState
    var baseChapters = [
        
        listModel(title: "保存与加载ARWorldMap", view: ARWorldMapSaveAndLoad()),
        listModel(title: "共享ARWorldMap", view: ARWorldMapShare()),
        listModel(title: "协作Session", view: CooperationSession()),
        listModel(title: "同步Session", view: SyncARSession()),
        listModel(title: "物理模拟", view: PhysicsBodyView()),
        listModel(title: "物理模拟2", view: PhysicsMotionView()),
        listModel(title: "触发器与触发域", view: TriggerVolumeView()),
        listModel(title: "3D文字", view: Text3DView()),
        listModel(title: "3D音频", view: Audio3DView()),
        listModel(title: "3D视频", view: Video3DView()),
        listModel(title: "AR Quick Look", view: ARQuickLookView())
        
    ]
    var body: some View {
        
        NavigationView {
            List(baseChapters, id: \.title) { model in
                NavigationLink(destination: AnyView( model.view ).onAppear(){
                    tabbar.hidden = true
                }.onDisappear(){
                    tabbar.hidden = false
                }) {
                    Text(model.title)
                }
            }
            .navigationTitle("进阶篇")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AdvancedChapterView()
}
