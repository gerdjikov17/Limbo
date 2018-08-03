//
//  AppDelegate.swift
//  Limbo
//
//  Created by A-Team User on 24.07.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotificationsUI
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIDevice.current.isBatteryMonitoringEnabled = true;
        let realm = try! Realm()
        let spectre = realm.objects(UserModel.self).filter("state = %@", "Spectre").first
        if spectre == nil {
            let spectre = UserModel(username: "Spectre", state: "Spectre", uniqueDeviceID: "Spectre")
            try! realm.write {
                realm.add(spectre)
            }
        }
        let center = UNUserNotificationCenter.current()
        // Request permission to display alerts and play sounds.
        center.requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
            // Enable or disable features based on authorization.
        }
        let messageCategory = UNNotificationCategory(identifier: Constants.Notifications.Identifiers.Message, actions: [], intentIdentifiers: [], options: .hiddenPreviewsShowTitle)
        let curseCategory = UNNotificationCategory(identifier: Constants.Notifications.Identifiers.Curse, actions: [], intentIdentifiers: [], options: .hiddenPreviewsShowTitle)
        center.setNotificationCategories([messageCategory, curseCategory])
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let uniqueDeviceID = userInfo["uniqueDeviceID"] as! String
        print(uniqueDeviceID)
    }


}

