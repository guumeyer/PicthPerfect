//
//  RecordSoundsViewController.swift
//  MeyerPitchPerfect
//
//  Created by Meyer, Gustavo on 1/30/19.
//  Copyright © 2019 Meyer. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {

    // MARK: - Outlets -

    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!

    // MARK: - Properties -

    let stopRecordingSegue = "stopRecording"
    var audioRecorder: AVAudioRecorder!

    // MARK: - View Life cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    // MARK: - Actions -

    @IBAction func recordAudio(_ sender: Any) {
        configureUI(text: "Recording in progress", isRecording: false)

        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))

        let session = AVAudioSession.sharedInstance()
        do{
            if #available(iOS 10.0, *) {
                try session.setCategory(.playback, mode: .default)
            } else {
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
            }

            try audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } catch {
            Alerts.showAlert(self, Alerts.RecordingDisabledTitle, message: Alerts.RecordingDisabledMessage)
        }
    }

    @IBAction func stopRecording(_ sender: Any) {
        configureUI(text: "Tap to Record", isRecording: true)
        audioRecorder.stop()
    }

    // MARK: - Configure UI

    func configureUI(text: String, isRecording: Bool){
        recordLabel.text = text
        recordLabel.sizeToFit()
        recordingButton.isEnabled = isRecording
        stopRecordingButton.isEnabled = !isRecording
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == stopRecordingSegue,
            let playSoundVC = segue.destination as?  PlaySoundsViewController,
                let recordedAudioURL = sender as? URL {
            playSoundVC.recordedAudioURL = recordedAudioURL
        }
    }
}

// MARK: - Extension RecordSoundsViewController: AVAudioRecorderDelegate -

extension RecordSoundsViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: stopRecordingSegue, sender: audioRecorder.url)
        } else {
            Alerts.showAlert(self, Alerts.RecordingFailedTitle, message: Alerts.RecordingFailedMessage)
        }
    }
}

