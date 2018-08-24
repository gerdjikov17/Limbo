//
//  ChatViewController+VoiceRecorderUIDelegate.swift
//  Limbo
//
//  Created by A-Team User on 21.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import NVActivityIndicatorView

extension ChatViewController: VoiceRecorderUIDelegate {
    func isReadyToRecord() {
        
        addVoiceRecordingView()
        self.voiceRecorder!.startRecording()
        print("recording")
    }
    
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
        let realm = try! Realm()
        try? realm.write {
            realm.add(message)
        }
        self.renameTempFile(newName: newFileName)
        print("finish recording")
    }
    
    
    @objc private func finishRecording() {
        removeButtons()
        self.voiceRecorder!.stopRecording()
    }
    
    @objc private func cancelRecording() {
        removeButtons()
        self.voiceRecorder!.cancelRecording()
        self.deleteTempFile()
    }
    
    private func removeButtons() {
        for view in self.view.subviews {
            if view.tag == 10 {
                view.removeFromSuperview()
            }
        }
    }
    
    private func deleteTempFile() {
        let limboFolder = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: true)
        let tempFileURL = limboFolder.appendingPathComponent("tempFile.mp3", isDirectory: false)
        try? FileManager.default.removeItem(at: tempFileURL)
    }
    
    private func renameTempFile(newName: String) {
        let limboFolder = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: true)
        let tempFileURL = limboFolder.appendingPathComponent("tempFile.mp4", isDirectory: false)
        let newFileURL = limboFolder.appendingPathComponent(newName, isDirectory: false)
        try? FileManager.default.moveItem(at: tempFileURL, to: newFileURL)
    }
    
    private func addVoiceRecordingView() {
        let emptyFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let voiceRecordingView = UIView(frame: emptyFrame)
        voiceRecordingView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        let finishButton = UIButton(frame: emptyFrame)
        finishButton.setTitle("Finish", for: UIControlState.normal)
        finishButton.addTarget(self, action: #selector(self.finishRecording), for: UIControlEvents.allTouchEvents)
        
        let cancelButton = UIButton(frame: emptyFrame)
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.addTarget(self, action: #selector(self.cancelRecording), for: UIControlEvents.allTouchEvents)
        
        let recordingAnimation = NVActivityIndicatorView(frame: emptyFrame, type: NVActivityIndicatorType.lineScalePulseOutRapid, color: .white, padding: 0)
        
        voiceRecordingView.addSubview(finishButton)
        voiceRecordingView.addSubview(cancelButton)
        voiceRecordingView.addSubview(recordingAnimation)
        
        recordingAnimation.startAnimating()
        voiceRecordingView.tag = 10
        self.view.addSubview(voiceRecordingView)

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        recordingAnimation.translatesAutoresizingMaskIntoConstraints = false
        voiceRecordingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: voiceRecordingView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: voiceRecordingView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: voiceRecordingView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150).isActive = true
        NSLayoutConstraint(item: voiceRecordingView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150).isActive = true
        
        NSLayoutConstraint(item: finishButton, attribute: .centerX, relatedBy: .equal, toItem: voiceRecordingView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: finishButton, attribute: .top, relatedBy: .equal, toItem: voiceRecordingView, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: finishButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60).isActive = true
        NSLayoutConstraint(item: finishButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25).isActive = true
        
        NSLayoutConstraint(item: cancelButton, attribute: .centerX, relatedBy: .equal, toItem: voiceRecordingView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: cancelButton, attribute: .bottom, relatedBy: .equal, toItem: voiceRecordingView, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60).isActive = true
        NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25).isActive = true
        
        NSLayoutConstraint(item: recordingAnimation, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50).isActive = true
        NSLayoutConstraint(item: recordingAnimation, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40).isActive = true
        NSLayoutConstraint(item: recordingAnimation, attribute: .centerX, relatedBy: .equal, toItem: voiceRecordingView, attribute: .centerX, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: recordingAnimation, attribute: .centerY, relatedBy: .equal, toItem: voiceRecordingView, attribute: .centerY, multiplier: 1.0, constant: 0).isActive = true
        
        self.view.bringSubview(toFront: voiceRecordingView)
        voiceRecordingView.layer.cornerRadius = 50
    }
    
}
