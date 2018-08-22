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
        message.receivers.append(self.userChattingWith!)
        let newFileName = message.additionalData!.base64EncodedString().suffix(10).replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "a").appending(".mp4")
        message.messageString = newFileName
        if let _ = self.chatDelegate?.sendMessage(messageModel: message, toPeerID: self.peerIDChattingWith!) {
            let realm = try! Realm()
            try? realm.write {
                realm.add(message)
            }
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
        let voiceRecordingView = UIView(frame: CGRect(x: view.center.x - 30, y: view.frame.height - 100, width: 60, height: 80))
        
        let finishButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 25))
        finishButton.setTitle("Finish", for: UIControlState.normal)
        finishButton.backgroundColor = .blue
        finishButton.addTarget(self, action: #selector(self.finishRecording), for: UIControlEvents.allTouchEvents)
        finishButton.tag = 10
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 35, width: 60, height: 25))
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.backgroundColor = .blue
        cancelButton.addTarget(self, action: #selector(self.cancelRecording), for: UIControlEvents.allTouchEvents)
        cancelButton.tag = 11
        
        voiceRecordingView.addSubview(finishButton)
        voiceRecordingView.addSubview(cancelButton)
//        finishButton.center.x = 0
//        cancelButton.center.x = 0
        voiceRecordingView.tag = 10
        self.view.addSubview(voiceRecordingView)

        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        voiceRecordingView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraint1 = NSLayoutConstraint(item: voiceRecordingView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0)
        let constraint2 = NSLayoutConstraint(item: voiceRecordingView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0)
        let constraint3 = NSLayoutConstraint(item: finishButton, attribute: .centerX, relatedBy: .equal, toItem: voiceRecordingView, attribute: .centerX, multiplier: 1.0, constant: 0)
        let constraint4 = NSLayoutConstraint(item: cancelButton, attribute: .centerX, relatedBy: .equal, toItem: voiceRecordingView, attribute: .centerX, multiplier: 1.0, constant: 0)
        let constraint5 = NSLayoutConstraint(item: cancelButton, attribute: .bottom, relatedBy: .equal, toItem: voiceRecordingView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let constraint6 = NSLayoutConstraint(item: finishButton, attribute: .top, relatedBy: .equal, toItem: voiceRecordingView, attribute: .top, multiplier: 1.0, constant: 0)
        let constraint7 = NSLayoutConstraint(item: finishButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
        let constraint8 = NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
        let constraint9 = NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25)
        let constraint10 = NSLayoutConstraint(item: finishButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25)
        let constraint11 = NSLayoutConstraint(item: voiceRecordingView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        let constraint12 = NSLayoutConstraint(item: voiceRecordingView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100)
        view.addConstraints([constraint11, constraint12, constraint1, constraint2])
        voiceRecordingView.addConstraints([constraint3, constraint4, constraint5, constraint6, constraint7, constraint8, constraint9, constraint10])
        
        self.view.bringSubview(toFront: voiceRecordingView)
        self.view.layoutIfNeeded()
        
        voiceRecordingView.layer.addScaleXAnimation(scaleFactor: 1.3)
        voiceRecordingView.layer.addScaleYAnimation(scaleFactor: 1.3)
    }
    
}
