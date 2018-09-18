//
//  VoiceRecorder.swift
//  Limbo
//
//  Created by A-Team User on 21.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import AVKit

class VoiceRecorder: NSObject {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder?
    var delegate: VoiceRecorderInteractorDelegate?
    
    init(delegate: VoiceRecorderInteractorDelegate) {
        recordingSession = AVAudioSession.sharedInstance()
        self.delegate = delegate
        let limboFolder = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: true)
        let fileURL = limboFolder.appendingPathComponent("tempFile.mp4", isDirectory: false)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        } catch {
            print(error)
        }
        super.init()
    }
    
    func startRecording() {
        try! recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! recordingSession.setActive(true)
        
        recordingSession.requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.audioRecorder!.delegate = self
                    self.audioRecorder!.record()
                } else {
                    // failed to record!
                }
            }
        }
        
    }
    
    func stopRecording() {
        audioRecorder!.stop()
    }
    
    func cancelRecording() {
        audioRecorder!.deleteRecording()
    }
    
    static func deleteTempFile() {
        let limboFolder = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: true)
        let tempFileURL = limboFolder.appendingPathComponent("tempFile.mp3", isDirectory: false)
        try? FileManager.default.removeItem(at: tempFileURL)
    }
    
    static func renameTempFile(newName: String) {
        let limboFolder = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: true)
        let tempFileURL = limboFolder.appendingPathComponent("tempFile.mp4", isDirectory: false)
        let newFileURL = limboFolder.appendingPathComponent(newName, isDirectory: false)
        try? FileManager.default.moveItem(at: tempFileURL, to: newFileURL)
    }
}

extension VoiceRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            self.delegate?.didFinishRecording()
        }
    }
}
