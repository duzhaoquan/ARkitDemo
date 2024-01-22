//
//  ARKitDeamoApp.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/9.
//

import SwiftUI
import Combine

@main
struct ARKitDeamoApp: App {
    let tabbar = TabBarState()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(tabbar).onAppear(){
                tabbar.$hidden.receive(subscriber: AnySubscriber(receiveSubscription: { sub in
                    sub.request(.unlimited)
                },receiveValue: { hidden in
                    tabBarHidden(hidden: hidden)
                    return .none
                }))
            }
        }
    }
    func tabBarHidden(hidden:Bool){
        if let mainWindow = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = mainWindow.windows.first?.rootViewController
        {
            for viewController in rootVC.children {
                if viewController.isKind(of: UITabBarController.self) {
                    let tabBarController = viewController as! UITabBarController
                    if tabBarController.tabBar.isHidden != hidden {
                        tabBarController.tabBar.isHidden = hidden
                    }
                    return
                }
            }
        }
        
    }
}
