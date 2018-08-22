//
//  VoiceMessageTableViewCell.swift
//  Limbo
//
//  Created by A-Team User on 21.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import AVKit

class VoiceMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var voiceProgressView: UIProgressView!
    @IBOutlet weak var timeStampLabel: UILabel!
    private var avPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func initialConfiguration(message: MessageModel) {
        timeStampLabel.text = SmartFormatter.formatDate(date: message.timeSent)
        
        let limboFolder = FileManager.getDocumentsDirectory().appendingPathComponent("Limbo", isDirectory: true)
        let fileURL = limboFolder.appendingPathComponent(message.messageString, isDirectory: false)
        avPlayer = try? AVAudioPlayer(contentsOf: fileURL)
        avPlayer?.delegate = self
        voiceProgressView.progress = 0
        playButton.addTarget(self, action: #selector(self.playButtonTap), for: UIControlEvents.touchUpInside)
        
    }
    
    @objc func playButtonTap() {
        guard avPlayer != nil else {
            return
        }
        if avPlayer!.isPlaying {
            avPlayer?.pause()
            timer?.invalidate()
            playButton.setTitle("Play", for: .normal)
        }
        else {
            avPlayer?.play()
            playButton.setTitle("Pause", for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateProgressView), userInfo: nil, repeats: true)
        }
    }

}

extension VoiceMessageTableViewCell: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setTitle("Play", for: .normal)
        timer?.invalidate()
        updateProgressView()
    }
    
    @objc func updateProgressView() {
        guard let currentTime = avPlayer?.currentTime, let duration = avPlayer?.duration else {
            timer?.invalidate()
            return
        }
        DispatchQueue.main.async {
            self.voiceProgressView.setProgress(Float(currentTime / duration), animated: false)
        }
    }
}
