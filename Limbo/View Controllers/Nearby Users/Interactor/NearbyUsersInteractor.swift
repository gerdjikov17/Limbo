//
//  NearbyUsersInteractor.swift
//  Limbo
//
//  Created by A-Team User on 27.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import RealmSwift
import MultipeerConnectivity
import UserNotifications

class NearbyUsersInteractor: NSObject {

    var presenter: NearbyUsersInteractorToPresenterInterface!
    
    var currentUser: UserModel! {
        return RealmManager.currentLoggedUser()
    }
    var notificationToken: NotificationToken?
    var chatRooms: [(peerID: MCPeerID, chatRoom: ChatRoomModel, unreadMessages: Int)]!
    var usersConnectivity: UsersConnectivity!
    var lastSelectedChatRoomUUID: String?
    var spectreManager: SpectreManager!
    
}

extension NearbyUsersInteractor: NearbyUsersPresenterToInteractorInterface {
    @objc func filterUsersToShow() {
        var newUsers: [(peerID: MCPeerID, chatRoom: ChatRoomModel, unreadMessages: Int)] = Array()
        var modelViews: [ChatRoomModelView] = Array()
        //        error here
        guard let chatRooms = self.chatRooms else {
            self.chatRooms = newUsers
            return
        }
        for chatRoom in chatRooms {
            if chatRoom.chatRoom.roomType == RoomType.GroupChat.rawValue || chatRoom.peerID.displayName == "C"{
                modelViews.append(ChatRoomModelView(chatRoom: chatRoom.chatRoom,
                                                    unreadMessages: chatRoom.unreadMessages,
                                                    state: "Group"))
            } else {
                modelViews.append(ChatRoomModelView(chatRoom: chatRoom.chatRoom,
                                                    unreadMessages: chatRoom.unreadMessages,
                                                    state: chatRoom.chatRoom.usersChattingWith.first!.state))
            }
            newUsers.append(chatRoom)
        }
        self.chatRooms = newUsers
        self.presenter.finishedSync(viewModels: modelViews)
    }
    
    func startLoopingForSpectres() {
        self.spectreManager = SpectreManager(nearbyUsersDelegate: self)
        self.spectreManager.startLoopingForSpectres()
    }
    
    func checkForCurses() {
        if let lastCurseCastDate = self.currentUser.curseCastDate {
            if lastCurseCastDate.timeIntervalSinceNow.isLess(than: Constants.Curses.curseTime) {
                CurseManager.removeCurse()
            }
            else {
                CurseManager.reApplyCurse(curse: Curse(rawValue: self.currentUser.curse)!,
                                          toUser: self.currentUser,
                                          remainingTime: lastCurseCastDate.timeIntervalSinceNow)
            }
        }
    }
    
    func initProperties() {
        self.chatRooms = Array()
        self.usersConnectivity = UsersConnectivity(userModel: self.currentUser, delegate: self, peerID: nil)
        self.usersConnectivity.chatDelegate = self
        self.currentUser.setState(batteryLevel: UIDevice.current.batteryLevel)
        self.notificationToken = self.currentUser.observe { (objectChange) in
            self.presenter.userObjectChanged(user: self.currentUser)
            self.filterUsersToShow()
        }
    }
    
    func setBatteryLevelForCurrentUser(batteryLevel: Float) {
        self.currentUser.setState(batteryLevel: batteryLevel)
    }
    
    func hasGifts() -> Bool {
        guard let gift = UserDefaults.standard.value(forKey: Constants.UserDefaults.gift) as? [String: Any] else { return false }
        guard gift["username"] as? String == RealmManager.currentLoggedUser()?.username else { return false }
        let date = gift["date"] as! Date
        let oneDayTimeInterval = -86400.0
        guard date.timeIntervalSinceNow > oneDayTimeInterval else { return false }
        return true
    }
    
    func userDidSignOut() {
        self.notificationToken?.invalidate()
        self.spectreManager.stopLoopingForSpectres()
        RealmManager.clearUsersStates()
        UserDefaults.standard.set(false, forKey: Constants.UserDefaults.isLoged)
        UserDefaults.standard.synchronize()
        self.usersConnectivity.didSignOut()
    }
    
    func isCurrentUserBlind() -> Bool {
        return self.currentUser.state == "Blind"
    }
    
    func chatRoom(forIndexPath indexPath: IndexPath) -> ChatRoomModel {
        return self.chatRooms[indexPath.row].chatRoom
    }
    
    func usersConnectivityDelegate() -> UsersConnectivityDelegate {
        return self.usersConnectivity
    }
    
    func replyAction(withText text: String, andUserInfo userInfo: [AnyHashable: Any]) -> (success: Bool, toastMessage: String?) {
        guard self.currentUser.curse != "Silence" else {
            let remainingTime = Constants.Curses.curseTime + (self.currentUser?.curseCastDate?.timeIntervalSinceNow)!
            let curseRemainingTime = Int(remainingTime)
            return (false, "You can't chat with people for \(curseRemainingTime) seconds")
        }
        let chatRoomUUID = userInfo["chatRoomUUID"] as! String
        guard let chatRoom = RealmManager.chatRoom(forUUID: chatRoomUUID) else {
            return(false, "Error sending message")
        }
        let messageModel = MessageModel(messageString: text, sender: self.currentUser, chatRoom: chatRoom)
        
        for user in chatRoom.usersChattingWith {
            let peerIDString = user.uniqueDeviceID
            if let peerIDSendingMessageTo = self.usersConnectivity.getPeerIDForUID(uniqueID: peerIDString) {
                _ = self.usersConnectivity!.sendMessage(messageModel: messageModel, toPeerID: peerIDSendingMessageTo)
            }
        }
        
        RealmManager.addNewMessage(message: messageModel)
        return (true, nil)
    }
    
    func inviteUsersIn(chatRoom: ChatRoomModel) {
        for peerIDString in chatRoom.usersPeerIDs {
            if let peerID = self.usersConnectivity.getPeerIDForUID(uniqueID: peerIDString) {
                if !self.usersConnectivity.session.connectedPeers.contains(peerID) {
                    self.usersConnectivity.inviteUser(peerID: peerID)
                }
            }
        }
    }
    
    func didSelectRoom(withUUID uuid: String?) {
        self.lastSelectedChatRoomUUID = uuid
        if let index = (self.chatRooms.index { arg -> Bool in
            arg.chatRoom.uuid == uuid
        }) {
            inviteUsersIn(chatRoom: self.chatRooms[index].chatRoom)
            self.chatRooms[index].unreadMessages = 0
        }
        
    }
    
    func addGroupChatCell() {
        guard !(self.chatRooms.contains(where: { arg -> Bool in
            arg.peerID.displayName == "C"
        })) else {
            return
        }
        
        
        let groupChatUser = UserModel(username: "Create Group", state: "Group", uniqueDeviceID: "GroupChat")
        groupChatUser.userID = Constants.groupChatAddID
        groupChatUser.avatarString = "group_chat_add_icon.png"
        let addGroopChatRoom = ChatRoomModel()
        addGroopChatRoom.avatar = groupChatUser.avatarString
        addGroopChatRoom.name = groupChatUser.username
        addGroopChatRoom.roomType = RoomType.CreateGroupChat.rawValue
        self.chatRooms.append((MCPeerID(displayName: "C"), chatRoom: addGroopChatRoom, unreadMessages: 0))
    }
    
    func showGroupChats() {
        guard !(self.chatRooms.contains(where: { arg -> Bool in
            arg.peerID.displayName == "Unnamed group"
        })) else {
            return
        }
        let realm = try! Realm()
        let realmChatRooms = realm.objects(ChatRoomModel.self).filter("usersChattingWith.@count > %d", 1)
        for chatRoom in realmChatRooms {
            if chatRoom.uuid.components(separatedBy: Constants.chatRoomSeparator).contains(self.currentUser.compoundKey) {
                self.chatRooms.append((MCPeerID(displayName: "Unnamed group"), chatRoom, 0))
            }
        }
    }
    
    func currentVisibleUsers() -> [UserModel]? {
        let users = self.chatRooms.compactMap({ arg -> UserModel? in
            if arg.chatRoom.usersChattingWith.count == 1 && arg.chatRoom.usersChattingWith.first!.userID == -1 {
                return arg.chatRoom.usersChattingWith.first
            }
            return nil
        })
        return users
    }
}

extension NearbyUsersInteractor: NearbyUsersDelegate {
    func didFindNewUser(user: UserModel, peerID: MCPeerID) {
        guard let realmChatRoom = RealmManager.chatRoom(forUUID: user.compoundKey) else { return }
        guard !(self.chatRooms.contains(where: { arg -> Bool in
            arg.peerID == peerID
        })) else { return }
        self.chatRooms.append(((peerID: peerID, chatRoom: realmChatRoom, unreadMessages: 0)))
        if user.state == "Spectre" {
            self.presenter.foundSpectre()
        }
        self.presenter.newChatRoom(chatRoomModelView:
            ChatRoomModelView(chatRoom: realmChatRoom, unreadMessages: 0, state: user.state))
    }
    
    func didFindNewChatRoom(chatRoomThreadSafeReference: ThreadSafeReference<ChatRoomModel>) {
        DispatchQueue.main.async {
            let realm = try! Realm()
            guard let chatRoom = realm.resolve(chatRoomThreadSafeReference) else { return }
            self.chatRooms.append((MCPeerID(displayName: "Unnamed group"), chatRoom, 0))
            self.presenter.newChatRoom(chatRoomModelView:
                ChatRoomModelView(chatRoom: chatRoom, unreadMessages: 0, state: "NewChatRoom"))
            
        }
    }
    
    func didLostUser(peerID: MCPeerID) {
        
        guard let index = (self.chatRooms.index { arg -> Bool in
            arg.peerID == peerID
        }) else { return }
        self.chatRooms.remove(at: index)
        
        if peerID.displayName == "Spectre" {
            self.presenter.lostSpectre()
        }
        
        self.filterUsersToShow()
    }
}


extension NearbyUsersInteractor: ChatDelegate {
    func didReceiveCurse(curse: Curse, remainingTime: Double) {
        
        DispatchQueue.main.async {
            if curse == .Blind {
                self.filterUsersToShow()
                
                let timer = Timer.init(fireAt: Date(timeIntervalSinceNow: remainingTime),
                                       interval: 0, target: self,
                                       selector: #selector(self.filterUsersToShow),
                                       userInfo: nil, repeats: false)
                
                RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
            }
        }
    }
    
    func didReceiveMessage(threadSafeMessageRef: ThreadSafeReference<MessageModel>, fromPeerID: MCPeerID) {
        DispatchQueue.main.async {
            let realm = try! Realm()
            let messageModel = realm.resolve(threadSafeMessageRef)
            
            if messageModel?.chatRoomUUID != self.lastSelectedChatRoomUUID {
                if let index = (self.chatRooms.index(where: { arg -> Bool in
                    arg.chatRoom.uuid == messageModel?.chatRoomUUID
                })) {
                    self.chatRooms[index].unreadMessages += 1
                }
                
                if let chatRoom = RealmManager.chatRoom(forUUID: messageModel!.chatRoomUUID) {
                    self.showNewMessageNotification(newMessage: messageModel!, forChatRoom: chatRoom)
                }
            }
            
            self.filterUsersToShow()
        }
    }
    
    private func showNewMessageNotification(newMessage messageModel: MessageModel, forChatRoom chatRoom: ChatRoomModel) {
        if chatRoom.roomType == RoomType.GroupChat.rawValue {
            if chatRoom.uuid.components(separatedBy: Constants.chatRoomSeparator).contains(self.currentUser.compoundKey) {
                NotificationManager.shared.presentNotification(withMessage: messageModel,
                                                               notificationDelegate: self.presenter as! UNUserNotificationCenterDelegate)
            }
        }
        else {
            NotificationManager.shared.presentNotification(withMessage: messageModel,
                                                           notificationDelegate: self.presenter as! UNUserNotificationCenterDelegate)
        }
    }
}

extension NearbyUsersInteractor: GroupChatDelegate {
    func createGroupChat(withUsers users: [UserModel]) {
        let chatRoom = ChatRoomModel(withUsers: users)
        if !RealmManager.hasChatRoomInRealm(chatRoom: chatRoom) {
            RealmManager.addChatRoom(chatRoom: chatRoom)
            self.chatRooms.append((MCPeerID(displayName: "Unnamed group"), chatRoom, 0))
            let chatModelView = ChatRoomModelView(chatRoom: chatRoom, unreadMessages: 0, state: "Group Chat")
            self.presenter.newChatRoom(chatRoomModelView: chatModelView)
        }
        let systemMessage = MessageModel(uuid: chatRoom.uuid, sender: self.currentUser)
        for user in users {
            if let peerID = self.usersConnectivity.getPeerIDForUID(uniqueID: user.uniqueDeviceID) {
                _ = self.usersConnectivity.sendMessage(messageModel: systemMessage, toPeerID: peerID)
            }
        }
    }
}
