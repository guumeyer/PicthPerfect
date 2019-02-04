//
//  PlaySoundsViewController.swift
//  MeyerPitchPerfect
//
//  Created by Meyer, Gustavo on 1/30/19.
//  Copyright © 2019 Meyer. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {

    // MARK: - Outlets -

    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var vaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var newRecordButton: UIButton!


    // MARK: - Properties -

    var recordedAudioURL: URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!

    enum ButtonType: Int {
        case slow = 0, fast, chipmunk, vader, echo, reverb
    }

    // MARK: - Life cycle -

    override func viewDidLoad() {
        super.viewDidLoad()

        snailButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        chipmunkButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        rabbitButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        vaderButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        echoButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        reverbButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        self.title = "Pitch Perfect"
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(.notPlaying)
        setupAudio()
    }

    // MARK: Actions

    @IBAction func playSoundForButton(_ sender: UIButton) {
        switch(ButtonType(rawValue: sender.tag)!) {
        case .slow:
            playSound(rate: 0.5)
        case .fast:
            playSound(rate: 1.5)
        case .chipmunk:
            playSound(pitch: 1000)
        case .vader:
            playSound(pitch: -1000)
        case .echo:
            playSound(echo: true)
        case .reverb:
            playSound(reverb: true)
        }

        configureUI(.playing)
    }

    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        stopAudio()
    }

    @IBAction func newRecordButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: - Extension PlaySoundsViewController: AVAudioPlayerDelegate -
extension PlaySoundsViewController: AVAudioPlayerDelegate {


    // MARK: - PlayingState -

    enum PlayingState { case playing, notPlaying }

    // MARK: - Audio Functions -

    func setupAudio() {
        // initialize (recording) audio file
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
        } catch {
            Alerts.showAlert(self, Alerts.AudioFileError, message: String(describing: error))
        }
    }

    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        // initialize audio engine components
        audioEngine = AVAudioEngine()

        // node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)

        // node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)

        // node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)

        // node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)

        // connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }

        // schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil) { [weak self] in
            guard let strongSelf = self else { return }

            var delayInSeconds: Double = 0

            if let lastRenderTime = strongSelf.audioPlayerNode.lastRenderTime, let playerTime = strongSelf.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {

                if let rate = rate {
                    delayInSeconds = Double(strongSelf.audioFile.length - playerTime.sampleTime) / Double(strongSelf.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    delayInSeconds = Double(strongSelf.audioFile.length - playerTime.sampleTime) / Double(strongSelf.audioFile.processingFormat.sampleRate)
                }
            }

            // schedule a stop timer for when audio finishes playing
            strongSelf.stopTimer = Timer(timeInterval: delayInSeconds, target: strongSelf, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(strongSelf.stopTimer!, forMode: RunLoop.Mode.default)
        }

        do {
            try audioEngine.start()
        } catch {
            Alerts.showAlert(self, Alerts.AudioEngineError, message: String(describing: error))
            return
        }

        // play the recording!
        audioPlayerNode.play()
    }

    @objc func stopAudio() {

        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }

        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }

        configureUI(.notPlaying)

        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }

    // MARK: - Connect List of Audio Nodes -

    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    // MARK: - UI Functions -
    func configureUI(_ playState: PlayingState) {
        switch(playState) {
        case .playing:
            configurinUI(enable: false)
        case .notPlaying:
            configurinUI(enable: true)
        }
    }

    func configurinUI(enable: Bool) {
        setPlayButtonsEnabled(enable)
        stopButton.isEnabled = !enable
    }

    func setPlayButtonsEnabled(_ enabled: Bool) {
        snailButton.isEnabled = enabled
        chipmunkButton.isEnabled = enabled
        rabbitButton.isEnabled = enabled
        vaderButton.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
        newRecordButton.isEnabled = enabled
    }

}
