//
//  IndustryXApp.swift
//  IndustryX
//
//  Created by Andryuchshenko Nikita on 17.03.2026.
//

import SwiftUI
import Firebase

@main
struct IndustryXApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var favorite = Favorite()
    
    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(favorite)
            //MainPageTabBar()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    print("Configured firebase!")
      
      
    return true
  }
}
