//
//  ChatPresenter+VoiceRecorderDelegate.swift
//  Limbo
//
//  Created by A-Team User on 24.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit

extension ChatInteractor: VoiceRecorderInteractorDelegate {
    
    func didFinishRecording() {
        let limboFolder = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: true)
        let tempFileURL = limboFolder.appendingPathComponent("tempFile.mp4", isDirectory: false)
        let message = MessageModel()
        message.sender = self.currentUser
        message.messageType = MessageType.Voice_Record.rawValue
        message.additionalData = try? Data(contentsOf: tempFileURL)
        
        let newFileName = message.additionalData!.base64EncodedString().suffix(10).replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "a").appending(".mp4")
        message.messageString = newFileName
        if (self.chatRoom?.usersChattingWith.count)! > 1 {
            message.chatRoomUUID = self.chatRoom!.uuid
        }
        else {
            message.chatRoomUUID = self.currentUser!.uniqueDeviceID.appending(self.currentUser!.username)
        }
        for user in chatRoom!.usersChattingWith {
            if let peerID = self.chatDelegate?.getPeerIDForUID(uniqueID: user.uniqueDeviceID) {
                _ = self.chatDelegate!.sendMessage(messageModel: message, toPeerID: peerID)
            }
        }
        message.chatRoomUUID = self.chatRoom!.uuid
        RealmManager.addNewMessage(message: message)
        self.voiceRecorder?.renameTempFile(newName: newFileName)
        print("finish recording")
    }
}
