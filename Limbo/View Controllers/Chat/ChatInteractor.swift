//
//  ChatInteractor.swift
//  Limbo
//
//  Created by A-Team User on 24.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

let KEY_COORDINATES = "coordinates"
let KEY_NAME = "name"
let KEY_ANSWER = "answer"

let QUESTION_NAME = "What is your name?"

import UIKit
import RealmSwift
import MultipeerConnectivity

class ChatInteractor: NSObject, ChatInteractorInterface {
    
    weak var chatPresenter: ChatInteractorToPresenterInterface!
    var chatDelegate: UsersConnectivityDelegate!
    var chatRoom: ChatRoomModel?
    var currentUser = RealmManager.currentLoggedUser()
    var messagesResults: Results<MessageModel>!
    var notificationToken: NotificationToken!
    
    var voiceRecorder: VoiceRecorder?
    
    init(chatDelegate: UsersConnectivityDelegate, chatPresenter: ChatInteractorToPresenterInterface, chatRoom: ChatRoomModel) {
        self.chatDelegate = chatDelegate
        self.chatPresenter = chatPresenter
        self.chatRoom = chatRoom
        self.messagesResults = RealmManager.getMessagesForChatRoom(firstUser: self.currentUser!, chatRoom: chatRoom)
        super.init()
        self.initNotificationToken()
    }
    
    deinit {
        self.notificationToken.invalidate()
    }
    
    func handleMessage(message: String) {
        guard message.count > 0 else { return }
        guard let chatRoom = self.chatRoom else { return }
        
        guard self.currentUser!.curse != Curse.Silence.rawValue else {
            self.chatPresenter.silencedCallBack()
            return
        }
        
        let antiCurseMessage = UserDefaults.standard.string(forKey: Constants.UserDefaults.antiCurse)
        let currentCurseCasterUniqueDeviceID = UserDefaults.standard.string(forKey:
            Constants.UserDefaults.curseUserUniqueDeviceID)
        
        if chatRoom.usersChattingWith.first!.state == "Spectre" {
            SpectreManager.sendMessageToSpectre(message: message)
        }
        else if message == antiCurseMessage && chatRoom.usersChattingWith.first!.uniqueDeviceID == currentCurseCasterUniqueDeviceID{
            CurseManager.removeCurse()
            NotificationManager.shared.presentItemNotification(withTitle: "Anti-Spell", andText: "You removed your curse with anti-spell")
        }
        else if chatRoom.roomType == RoomType.Game.rawValue {
            self.sendMessageToGame(message: message, chatRoom: chatRoom)
        }
        else {
            let message = self.currentUser?.curse == Curse.Posession.rawValue ? message.shuffle() : message
            self.send(message: message, toChatRoom: chatRoom)
        }
    }
    
    func send(message: String, toChatRoom chatRoom: ChatRoomModel) {
        let messageModel = MessageModel(messageString: message, sender: self.currentUser!, chatRoom: chatRoom)
        
        for user in chatRoom.usersChattingWith {
            if let peerID = self.chatDelegate.getPeerIDForUID(uniqueID: user.uniqueDeviceID) {
                _ = self.chatDelegate.sendMessage(messageModel: messageModel, toPeerID: peerID)
            }
        }
        messageModel.chatRoomUUID = chatRoom.uuid
        RealmManager.addNewMessage(message: messageModel)
    }
    
    func sendMessageToGame(message: String, chatRoom: ChatRoomModel) {
        
        let messageBeforeThis = self.messagesResults.last?.messageString
        var key: String

        if messageBeforeThis == QUESTION_NAME {
            key = KEY_NAME
        }
        else if messageBeforeThis!.contains("|") || messageBeforeThis!.contains("Invalid") {
            key = KEY_COORDINATES
        }
        else {
            key = KEY_ANSWER
        }
        let dataDict = [key: message]
        
        let messageModel = MessageModel(messageString: message, sender: self.currentUser!, chatRoom: chatRoom)
        RealmManager.addNewMessage(message: messageModel)
        
        let success = self.chatDelegate!.sendJSONtoGame(dataDict: dataDict,
                                                        toPeerID: (self.chatDelegate!.getPeerIDForUID(uniqueID: chatRoom.usersPeerIDs.first!)!))
    }
    
    func initNotificationToken() {
        self.notificationToken = self.messagesResults.observe({ changes in
            switch changes {
            case .initial:
                print()
            case .update(_, _, let insertions, _):
                
                if insertions.count > 0 {
                    print("new insertion\n\n")
                    self.chatPresenter.newMessage(message: self.messagesResults.last!)
                }
            case .error(let error):
                print(error)
            }
        })
    }
    
    func invalidateToken() {
        self.notificationToken.invalidate()
    }
    
    func didStartPresentingSomeVC() {
        self.initNotificationToken()
    }
    
    func getMessageResults() -> Results<MessageModel>? {
        return self.messagesResults
    }
    
    func currentRoomName() -> String {
        return chatRoom!.name
    }
    
    func currentRoom() -> ChatRoomModel {
        return chatRoom!
    }
    
    func changeRoomName(newName: String) {
        let realm = try! Realm()
        try! realm.write {
            self.chatRoom!.name = newName
        }
    }
    
    func clearHistory(completionHandler: ()) {
        let realm = try! Realm()
        realm.beginWrite()
        realm.delete(self.messagesResults)
        try! realm.commitWrite()
        completionHandler
    }
    
    func finishedPickingImage(pickedImage: UIImage) {
        
        let imageData = UIImageJPEGRepresentation(pickedImage, 1.0)
        var imageName = imageData?.base64EncodedString().suffix(10).appending(".jpeg")
        imageName = imageName?.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "a")
        
        let message = MessageModel(messageType: .Photo, additionalData: imageData,
                                   dataName: imageName!, sender: self.currentUser!,
                                   chatRoom: chatRoom!)
    
        let fileToSaveTo = FileManager.getDocumentsDirectory()
            .appendingPathComponent("Limbo", isDirectory: true)
            .appendingPathComponent(imageName!, isDirectory: false)
        do {
            try imageData?.write(to: fileToSaveTo, options: Data.WritingOptions.atomic)
        }
        catch {
            print(error)
        }
        for user in chatRoom!.usersChattingWith {
            if let peerID = self.chatDelegate?.getPeerIDForUID(uniqueID: user.uniqueDeviceID) {
                _ = self.chatDelegate!.sendMessage(messageModel: message, toPeerID: peerID)
            }
        }
        message.additionalData = nil
        message.chatRoomUUID = self.chatRoom!.uuid
        RealmManager.addNewMessage(message: message)
    }
}

extension ChatInteractor: VoiceRecorderInteractorDelegate {
    
    func didFinishRecording() {
        self.initNotificationToken()
        
        let limboFolder = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: true)
        let tempFileURL = limboFolder.appendingPathComponent("tempFile.mp4", isDirectory: false)
        
        guard let fileData = try? Data(contentsOf: tempFileURL) else { return }
        
        let newFileName = fileData.base64EncodedString()
            .suffix(10)
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "a").appending(".mp4")
        
        let message = MessageModel(messageType: .Voice_Record, additionalData: fileData,
                                   dataName: newFileName, sender: currentUser!,
                                   chatRoom: chatRoom!)
        
        for user in chatRoom!.usersChattingWith {
            if let peerID = self.chatDelegate?.getPeerIDForUID(uniqueID: user.uniqueDeviceID) {
                _ = self.chatDelegate!.sendMessage(messageModel: message, toPeerID: peerID)
            }
        }
        message.chatRoomUUID = self.chatRoom!.uuid
        RealmManager.addNewMessage(message: message)
        VoiceRecorder.renameTempFile(newName: newFileName)
        print("finish recording")
    }
}
