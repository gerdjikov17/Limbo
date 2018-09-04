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
        let realm = try! Realm()
        realm.autorefresh = true
        let spectre = realm.objects(UserModel.self).filter("state = %@", "Spectre").first
        if spectre == nil {
            let spectre = UserModel(username: "Spectre", state: "Spectre", uniqueDeviceID: "Spectre")
            let chatRoom = ChatRoomModel()
            try! realm.write {
                realm.add(spectre)
                spectre.userID = -2
                chatRoom.usersChattingWith.append(spectre)
                chatRoom.roomType = RoomType.SingleUserChat.rawValue
                chatRoom.uuid = spectre.compoundKey
                chatRoom.name = spectre.username
                realm.add(chatRoom)
            }
        }
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            let replyAction = UNTextInputNotificationAction(identifier: Constants.Notifications.Identifiers.MessageActionReply,
                                                            title: "Reply", options: [], textInputButtonTitle: "Reply",
                                                            textInputPlaceholder: "Write a message...")
            
            let messageCategory = UNNotificationCategory(identifier: Constants.Notifications.Identifiers.Message,
                                                         actions: [replyAction], intentIdentifiers: [], options: [])
            
            let candleAction = UNNotificationAction(identifier: Constants.Notifications.Identifiers.CurseActionItemCandle,
                                                    title: "Use Holy Candle", options: [])
            
            let medallionAction = UNNotificationAction(identifier: Constants.Notifications.Identifiers.CurseActionItemMedallion,
                                                       title: "Use Saint's Medallion", options: [])
            
            let curseCategory = UNNotificationCategory(identifier: Constants.Notifications.Identifiers.Curse,
                                                       actions: [candleAction, medallionAction],
                                                       intentIdentifiers: [], options: [])
            
            let itemCategory = UNNotificationCategory(identifier: Constants.Notifications.Identifiers.Item,
                                                      actions: [], intentIdentifiers: [], options: [])
            
            center.setNotificationCategories([messageCategory, curseCategory, itemCategory])
        }
        try? FileManager.default.createDirectory(
            at: FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: true),
            withIntermediateDirectories: true, attributes: nil)
        
        let nearbyUVC = NearbyUsersRouter.createNearbyUsersModule()
        
        window = UIWindow(frame: UIScreen.main.bounds);
        window?.rootViewController = nearbyUVC
        window?.makeKeyAndVisible();
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

        print("\n clears user status\n")
        UserDefaults.standard.set(nil, forKey: Constants.UserDefaults.antiCurse)
        UserDefaults.standard.synchronize()
        RealmManager.clearUsersStates()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let uniqueDeviceID = userInfo["uniqueDeviceID"] as! String
        print(uniqueDeviceID)
    }


}

