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
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Play slow sound
    @IBAction func playSlowSound(sender: UIButton) {
        playSound(0.0, rate: 0.8, echo: false)
    }
    
    // Play fast sound
    @IBAction func playFastSound(sender: UIButton) {
        playSound(0.0, rate: 1.2, echo: false)
    }

    // Play chipmunk sound
    @IBAction func playChipmunkAudio(sender: AnyObject) {
        playSound(1000, rate: 1.0, echo: false)
    }
    
    // Play darthvader sound
    @IBAction func playDarthvaderAudio(sender: AnyObject) {
        playSound(-1000, rate: 1.0, echo: false)
    }
    
    // Play sound with echo
    @IBAction func playEcho(sender: AnyObject) {
        playSound(0.0, rate: 1.0, echo: true)
    }
    
    // Stop playback
    @IBAction func stopSound(sender: UIButton) {
        audioEngine.stop()
        audioEngine.reset()
    }
    
    // Play sound dependent of the given parameter
    func playSound(pitch: Float, rate: Float, echo: Bool){
        
        // stop audio engine first
        audioEngine.stop()
        audioEngine.reset()
        
        // initialize the audio session and set the audio output to default speaker (bottom)
        let session = AVAudioSession.sharedInstance()
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker, error: nil){
            println("could not set session category")
        }
        
        // activate audio session
        if !session.setActive(true, error: nil){
            println("could not activate session")
        }
        
        // attach audio player and sound effect nodes to audio engine
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var pitchEffect = AVAudioUnitTimePitch()
        pitchEffect.pitch = pitch
        audioEngine.attachNode(pitchEffect)

        var rateEffect = AVAudioUnitVarispeed()
        rateEffect.rate = rate
        audioEngine.attachNode(rateEffect)
        
        var distortionEffect = AVAudioUnitDistortion()
        distortionEffect.loadFactoryPreset(AVAudioUnitDistortionPreset.MultiEcho2)
        audioEngine.attachNode(distortionEffect)
        
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
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
}
