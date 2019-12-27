//
//  AppDelegate.swift
//  MentorGlass
//
//  Created by Ren Matsushita on 2019/12/26.
//  Copyright © 2019 Ren Matsushita. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        window?.rootViewController = selectRootViewController()
        window?.makeKeyAndVisible()
        return true
    }
    
    func selectRootViewController() -> UIViewController {
        let mentorGlassStoryboard = UIStoryboard(name: "MentorGlass", bundle: nil)
        let mentorGlassViewController = mentorGlassStoryboard.instantiateViewController(identifier: "MentorGlass")
        return mentorGlassViewController
    }
}

