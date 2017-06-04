//
//  PlaySoundsViewController.swift
//  Piffy Poffy
//
//  Created by Sascha Stanic on 21.03.15.
//  Copyright (c) 2015 Sascha Stanic. All rights reserved.
//

import UIKit;
import AVFoundation;

class PlaySoundsViewController: UIViewController {

    var avPlayer:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize audio engine and audio file
        audioEngine = AVAudioEngine()
        do {
            try audioFile = AVAudioFile(forWriting: receivedAudio.filePathUrl as URL, settings: [:])
        } catch {
            print("Could not initialize audio engine")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Play slow sound
    @IBAction func playSlowSound(_ sender: UIButton) {
        playSound(0.0, rate: 0.8, echo: false)
    }
    
    // Play fast sound
    @IBAction func playFastSound(_ sender: UIButton) {
        playSound(0.0, rate: 1.2, echo: false)
    }

    // Play chipmunk sound
    @IBAction func playChipmunkAudio(_ sender: AnyObject) {
        playSound(1000, rate: 1.0, echo: false)
    }
    
    // Play darthvader sound
    @IBAction func playDarthvaderAudio(_ sender: AnyObject) {
        playSound(-1000, rate: 1.0, echo: false)
    }
    
    // Play sound with echo
    @IBAction func playEcho(_ sender: AnyObject) {
        playSound(0.0, rate: 1.0, echo: true)
    }
    
    // Stop playback
    @IBAction func stopSound(_ sender: UIButton) {
        audioEngine.stop()
        audioEngine.reset()
    }
    
    // Play sound dependent of the given parameter
    func playSound(_ pitch: Float, rate: Float, echo: Bool){
        
        // stop audio engine first
        audioEngine.stop()
        audioEngine.reset()
        
        let session = AVAudioSession.sharedInstance()
        // initialize the audio session and set the audio output to default speaker (bottom)
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            print("Could not initialize audio session.")
        }
        
        
        // activate audio session
        do {
            try session.setActive(true)
        } catch {
            print("could not activate session")
        }
        
        // attach audio player and sound effect nodes to audio engine
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        let pitchEffect = AVAudioUnitTimePitch()
        pitchEffect.pitch = pitch
        audioEngine.attach(pitchEffect)

        let rateEffect = AVAudioUnitVarispeed()
        rateEffect.rate = rate
        audioEngine.attach(rateEffect)
        
        let distortionEffect = AVAudioUnitDistortion()
        distortionEffect.loadFactoryPreset(AVAudioUnitDistortionPreset.multiEcho2)
        audioEngine.attach(distortionEffect)
        
        // connect all nodes together. Echo has no parameter to switch it off: Need to skip it if not used
        audioEngine.connect(audioPlayerNode, to: pitchEffect, format: nil)
        audioEngine.connect(pitchEffect, to: rateEffect, format: nil)
        
        if (echo){
            audioEngine.connect(rateEffect, to: distortionEffect, format: nil)
            audioEngine.connect(distortionEffect, to: audioEngine.outputNode, format: nil)
        }
        else {
            audioEngine.connect(rateEffect, to: audioEngine.outputNode, format: nil)
        }

        // Play the audio file with the chosen audio effect
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        do {
            try audioEngine.start()
        } catch {
            print("Could not play the audio file")
        }
        
        audioPlayerNode.play()
    }
}
