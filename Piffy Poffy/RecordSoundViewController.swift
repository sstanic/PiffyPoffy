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
    var currentTime:NSTimeInterval!
    let isReady = 0
    let isRecording = 1
    let isPause = 2
    let isFinished = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        switchToStatusReadyForRecording()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Segue from recording screen to playback screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording"){
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }

    // Record audio with the possibility to pause.
    @IBAction func recordAudio(sender: UIButton) {
        if (recordingStatus == isPause){
            audioRecorder.recordAtTime(currentTime)
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
    @IBAction func stopRecording(sender: UIButton) {
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    // Initialize a new audio file and the audio recorder.
    func initializeNewAudioFile(){
        
        // define directory path
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        // define file path and file name
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        // create audio session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        // create audio recorder with previously defined file path/name
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
    }
    
    // Prepare audio data model with recording information and perform segue to playback screen.
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag){
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
        else{
            println("Recording was not successful")
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
        stopButton.hidden = true;
        micButton.setImage(micImage, forState: .Normal)
    }
    
    // Recording started.
    // - Label shows 'recording'
    // - Stop button is visible
    // - Microphone button shows pause image
    func switchToStatusRecording(){
        recordingStatus = isRecording
        recordingInProgress.text = recordingText
        stopButton.hidden = false;
        micButton.setImage(pauseImage, forState: .Normal)
    }
    
    // The recording is paused.
    // - Label text shows 'paused'
    // - Microphone button shows mic image
    // - Current time saved
    func switchToStatusRecordPausing(){
        recordingStatus = isPause
        recordingInProgress.text = pauseText
        micButton.setImage(micImage, forState: .Normal)
        currentTime = audioRecorder.currentTime
    }
    
    // The recording is finished.
    // - Clear label text
    func switchToStatusRecordFinished(){
        recordingStatus = isFinished
        recordingInProgress.text = ""
    }
}

