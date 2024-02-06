//
//  ContentView.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/9.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var tabbar: TabBarState
    var body: some View {
        TabView{
            BaseChapterView()
                .environmentObject(tabbar)
                .tabItem {
                    Image(systemName: "goforward")
                    Text("基础篇")
                }.tag(0)
            
            FunctionalTechnology()
                .environmentObject(tabbar)
                .tabItem {
                    Image(systemName: "rectangle.on.rectangle")
                    Text("技术篇")
                }.tag(1)
            BaseChapterView()
                .environmentObject(tabbar)
                .tabItem {
                    Image(systemName: "smiley")
                    Text("提高篇")
                }.tag(2)
        }
        
    }
}

#Preview {
    ContentView()
}

class TabBarState: ObservableObject{
    @Published var hidden: Bool = false
}
