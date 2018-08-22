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
    var delegate: VoiceRecorderUIDelegate?
    
    override init() {
        recordingSession = AVAudioSession.sharedInstance()
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
        
//        audioRecorder = try! AVAudioRecorder(url: fileURL, settings: settings)
        try! recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! recordingSession.setActive(true)
        super.init()
        recordingSession.requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.delegate?.isReadyToRecord()
                } else {
                    // failed to record!
                }
            }
        }
    }
    
    func startRecording() {
        audioRecorder!.delegate = self
        audioRecorder!.record()
    }
    
    func stopRecording() {
        audioRecorder!.stop()
    }
    
    func cancelRecording() {
        audioRecorder!.deleteRecording()
    }
}

extension VoiceRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            self.delegate?.didFinishRecording()
        }
    }
}
