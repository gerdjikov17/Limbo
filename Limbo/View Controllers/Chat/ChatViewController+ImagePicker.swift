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
            
            let realm = try! Realm()
            realm.beginWrite()
            message.additionalData = nil            
            message.chatRoomUUID = self.chatRoom!.uuid
            realm.add(message)
            try! realm.commitWrite()
            realm.refresh()
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapOnImage(recognizer: UITapGestureRecognizer) {
        let touchPoint = recognizer.location(in: self.chatTableView)
        let indexPath: IndexPath = self.chatTableView.indexPathForRow(at: touchPoint)!
        guard let cell = self.chatTableView.cellForRow(at: indexPath) as? PhotoTableViewCell else {
            return
        }
        guard let image = cell.sentPhotoImageView.image else {
            return
        }
        let message = self.messages[indexPath.row]
        guard let sender = message.sender else {
            return
        }
        let chatImageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatImageVC") as! ChatImageViewController
        chatImageVC.image = image
        chatImageVC.senderUsername = sender.username
        self.navigationController!.present(chatImageVC, animated: true, completion: nil)
        
    }
}
