//
//  AppDelegate.swift
//  PatternCollection
//
//  Created by caishilin on 2024/6/5.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootTabBarController()
        window?.makeKeyAndVisible()
        return true
    }
}

