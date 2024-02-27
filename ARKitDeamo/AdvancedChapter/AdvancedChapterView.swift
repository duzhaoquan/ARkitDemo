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
        listModel(title: "人形遮挡", view: HumanOcclusionView()),
        listModel(title: "人形获取", view: HumanExtraction()),
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
