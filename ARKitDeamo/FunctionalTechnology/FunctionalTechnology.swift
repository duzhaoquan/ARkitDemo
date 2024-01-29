//
//  FunctionalTechnology.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/18.
//

import SwiftUI

struct FunctionalTechnology: View {
    @EnvironmentObject var tabbar: TabBarState
    var baseChapters = [
        listModel(title: "DirectionaLight", view: DirectionalLightView()),
        listModel(title: "PointLight", view: PointLightView()),
        listModel(title: "SpotLight", view: SpotLightView()),
        listModel(title: "图像检测", view: ImageChecking()),
        listModel(title: "3D物体检测", view: ObjectChceking()),
        listModel(title: "3D物体扫描与检测", view: ObjectScanning()),
        listModel(title: "人脸检测", view: FaceChecking()),
        listModel(title: "BlendShape", view: BlendShapeView()),
        listModel(title: "光照估计", view: LightEstimate()),
        
        
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
            .navigationTitle("提高篇")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}

#Preview {
    FunctionalTechnology()
}
