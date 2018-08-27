//
//  VoiceRecordingViewController.swift
//  Limbo
//
//  Created by A-Team User on 27.08.18.
//  Copyright © 2018 A-Team User. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class VoiceRecordingViewController: UIViewController {

    @IBOutlet weak var greyContainerView: UIView!
    @IBOutlet weak var recordingActivityIndicator: NVActivityIndicatorView!
    
    var voiceRecorderDelegate: VoiceRecorderInteractorDelegate?
    var voiceRecorder: VoiceRecorder?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.recordingActivityIndicator.type = .lineScalePulseOutRapid
        self.recordingActivityIndicator.color = .white
        self.recordingActivityIndicator.startAnimating()
        self.greyContainerView.layer.cornerRadius = 40
        
        self.voiceRecorder = VoiceRecorder(delegate: self.voiceRecorderDelegate!)
        self.voiceRecorder?.startRecording()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func finishButtonTap(_ sender: Any) {
        self.voiceRecorder?.stopRecording()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTap(_ sender: Any) {
        self.voiceRecorder?.cancelRecording()
        VoiceRecorder.deleteTempFile()
        self.dismiss(animated: true, completion: nil)
    }

}
