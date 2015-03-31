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
        
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playSlowSound(sender: UIButton) {
        playSound(0.0, rate: 0.8, echo: false)
    }
    
    @IBAction func playFastSound(sender: UIButton) {
        playSound(0.0, rate: 1.2, echo: false)
    }

    @IBAction func playChipmunkAudio(sender: AnyObject) {
        playSound(1000, rate: 1.0, echo: false)
    }
    
    @IBAction func playDarthvaderAudio(sender: AnyObject) {
        playSound(-1000, rate: 1.0, echo: false)
    }
    
    @IBAction func playEcho(sender: AnyObject) {
        playSound(0.0, rate: 1.0, echo: true)
    }
    
    @IBAction func stopSound(sender: UIButton) {
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func playSound(pitch: Float, rate: Float, echo: Bool){
        audioEngine.stop()
        audioEngine.reset()
        
        let session = AVAudioSession.sharedInstance()
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker, error: nil){
            println("could not set session category")
        }
        
        if !session.setActive(true, error: nil){
            println("could not activate session")
        }
        
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
        
        audioEngine.connect(audioPlayerNode, to: pitchEffect, format: nil)
        audioEngine.connect(pitchEffect, to: rateEffect, format: nil)
        
        if (echo){
            audioEngine.connect(rateEffect, to: distortionEffect, format: nil)
            audioEngine.connect(distortionEffect, to: audioEngine.outputNode, format: nil)
        }
        else {
            audioEngine.connect(rateEffect, to: audioEngine.outputNode, format: nil)
        }

        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
