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
        realm.autorefresh = true
        let spectre = realm.objects(UserModel.self).filter("state = %@", "Spectre").first
        if spectre == nil {
            let spectre = UserModel(username: "Spectre", state: "Spectre", uniqueDeviceID: "Spectre")
            try! realm.write {
                realm.add(spectre)
                spectre.userID = -2
            }
        }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound])
        { (granted, error) in
            let replyAction = UNTextInputNotificationAction(identifier: Constants.Notifications.Identifiers.MessageActionReply, title: "Reply", options: [], textInputButtonTitle: "Reply", textInputPlaceholder: "Write a message...")
            let messageCategory = UNNotificationCategory(identifier: Constants.Notifications.Identifiers.Message, actions: [replyAction], intentIdentifiers: [], options: [])
            
            let candleAction = UNNotificationAction(identifier: Constants.Notifications.Identifiers.CurseActionItemCandle, title: "Use Holy Candle", options: [])
            let medallionAction = UNNotificationAction(identifier: Constants.Notifications.Identifiers.CurseActionItemMedallion, title: "Use Saint's Medallion", options: [])
            let curseCategory = UNNotificationCategory(identifier: Constants.Notifications.Identifiers.Curse, actions: [candleAction, medallionAction], intentIdentifiers: [], options: [])
            
            let itemCategory = UNNotificationCategory(identifier: Constants.Notifications.Identifiers.Item, actions: [], intentIdentifiers: [], options: [])
            center.setNotificationCategories([messageCategory, curseCategory, itemCategory])
        }
        try? FileManager.default.createDirectory(at: FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: true), withIntermediateDirectories: true, attributes: nil)
        
        let nearbyUVC = NearbyUsersRouter.createNearbyUsersModule()
        
        window = UIWindow(frame: UIScreen.main.bounds);
        window?.rootViewController = nearbyUVC
        window?.makeKeyAndVisible();
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("\n clears user status\n")
        UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.antiCurse)
        UserDefaults.standard.synchronize()
        RealmManager.clearUsersStates()
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

