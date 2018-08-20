//
//  ChatViewController+ImagePicker.swift
//  Limbo
//
//  Created by A-Team User on 15.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let message = MessageModel()
            message.messageType = MessageType.Photo.rawValue
            message.additionalData = UIImageJPEGRepresentation(pickedImage, 1.0)
            message.sender = self.currentUser!
            var imageName = message.additionalData?.base64EncodedString().suffix(10).appending(".jpeg")
            imageName = imageName?.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "a")
            message.messageString = imageName!
            let fileToSaveTo = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: true).appendingPathComponent(imageName!, isDirectory: false)
            do {
                try message.additionalData?.write(to: fileToSaveTo, options: Data.WritingOptions.atomic)
            }
            catch {
                print(error)
            }
            
            
            if let _ = self.chatDelegate?.sendMessage(messageModel: message, toPeerID: self.peerIDChattingWith!) {
                let realm = try! Realm()
                if let userChattingWith = self.userChattingWith {
                    realm.beginWrite()
                    message.additionalData = nil
                    message.receivers.append(userChattingWith)
                    realm.add(message)
                    try! realm.commitWrite()
                    realm.refresh()
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
