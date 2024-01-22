//
//  BaseChapterView.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/12.
//

import SwiftUI


struct BaseChapterView: View {
    @EnvironmentObject var tabbar: TabBarState
    var baseChapters = [
        listModel(title: "第二章 ", view: ARCoachingView()),
        listModel(title: "第二章 简单的手势操作", view: ARGescherView()),
        listModel(title: "第二章 截屏", view: ShapShoptView()),
        listModel(title: "第二章 可视化检测到的平面", view: CheckingsPlaneShowView()),
        listModel(title: "第二章 射线检测与手势操作", view: RayCheckingAndGestureView()),
        listModel(title: "第二章 手势操作", view: GestureControlView()),
        listModel(title: "第二章 显示特征点与世界坐标原点", view: AnchorGeometryView()),
        listModel(title: "第二章 Reality 事件系统", view: RealityKitEventView()),
        listModel(title: "第三章 骨骼动画", view: BoneAnimationView()),
        listModel(title: "第三章 同步加载与异步加载", view: AsyncLoadView()),
        listModel(title: "第三章 Transform", view: TransformView()),
    ]
    var body: some View {
        
        NavigationView {
            List(baseChapters, id: \.title) { model in
                NavigationLink(destination: AnyView( model.view.onAppear(){
                    self.tabbar.hidden = true
                }.onDisappear(){
                    self.tabbar.hidden = false
                } )) {
                    Text(model.title)
                }
            }
            .navigationTitle("基础篇")
            .navigationBarTitleDisplayMode(.inline)
            
            
            
        }.onAppear(){
            self.tabbar.hidden = false
        }
    }
}

struct listModel {
    var title:String
    var view:  any View
}

struct AnchorView : View{
    var body: some View {
        HStack{
            Text("hello")
        }
    }
}
