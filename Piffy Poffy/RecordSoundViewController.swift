//
//  RecordSoundViewController.swift
//  Piffy Poffy
//
//  Created by Sascha Stanic on 22.02.15.
//  Copyright (c) 2015 Sascha Stanic. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!

    // label text
    let tapToRecordText = "tap to record audio"
    let recordingText = "recording audio"
    let pauseText = "recording paused, tap to continue"
    
    // button images
    let stopImage = UIImage(named: "stop")
    let pauseImage = UIImage(named: "pause")
    let micImage = UIImage(named: "microphone")

    // recording status
    var recordingStatus:Int!
    var currentTime:TimeInterval!
    let isReady = 0
    let isRecording = 1
    let isPause = 2
    let isFinished = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        switchToStatusReadyForRecording()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Segue from recording screen to playback screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "stopRecording"){
            let playSoundsVC:PlaySoundsViewController = segue.destination as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }

    // Record audio with the possibility to pause.
    @IBAction func recordAudio(_ sender: UIButton) {
        if (recordingStatus == isPause){
            audioRecorder.record(atTime: currentTime)
            switchToStatusRecording()
        }
        else if (recordingStatus == isRecording) {
            audioRecorder.pause()
            switchToStatusRecordPausing()
        }
        else if (recordingStatus == isReady){
            switchToStatusRecording()
            initializeNewAudioFile()
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        }
    }
    
    // Stop recording
    @IBAction func stopRecording(_ sender: UIButton) {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            print("Could not set inactive")
        }
    }
    
    // Initialize a new audio file and the audio recorder.
    func initializeNewAudioFile(){
        
        // define directory path
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        
        // define file path and file name
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.string(from: currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURL(withPathComponents: pathArray)
        print(filePath as Any)
        
        // create audio session
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            print("Could not set category")
        }
        
        // create audio recorder with previously defined file path/name
        var audioRecorder: AVAudioRecorder
        do {
            try
                audioRecorder = AVAudioRecorder(url: filePath!, settings: [:]);
                audioRecorder.delegate = self;
                audioRecorder.isMeteringEnabled = true
            
        } catch {
            print("Can not create audio recorder.")
        }
    }
    
    // Prepare audio data model with recording information and perform segue to playback screen.
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag){
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent)
            performSegue(withIdentifier: "stopRecording", sender: recordedAudio)
        }
        else{
            print("Recording was not successful")
            switchToStatusReadyForRecording()
        }
    }
    
    // Ready for recording.
    // - Label text shows 'tap to record'
    // - Stop button is hidden
    // - Microphone button shows microphone image
    func switchToStatusReadyForRecording(){
        recordingStatus = isReady
        recordingInProgress.text = tapToRecordText
        stopButton.isHidden = true;
        micButton.setImage(micImage, for: UIControlState())
    }
    
    // Recording started.
    // - Label shows 'recording'
    // - Stop button is visible
    // - Microphone button shows pause image
    func switchToStatusRecording(){
        recordingStatus = isRecording
        recordingInProgress.text = recordingText
        stopButton.isHidden = false;
        micButton.setImage(pauseImage, for: UIControlState())
    }
    
    // The recording is paused.
    // - Label text shows 'paused'
    // - Microphone button shows mic image
    // - Current time saved
    func switchToStatusRecordPausing(){
        recordingStatus = isPause
        recordingInProgress.text = pauseText
        micButton.setImage(micImage, for: UIControlState())
        currentTime = audioRecorder.currentTime
    }
    
    // The recording is finished.
    // - Clear label text
    func switchToStatusRecordFinished(){
        recordingStatus = isFinished
        recordingInProgress.text = ""
    }
}

