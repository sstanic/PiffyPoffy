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
    
    let tapToRecordText = "tap to record audio"
    let recordingText = "recording audio"
    let pauseText = "recording paused, tap to continue"
    
    let stopImage = UIImage(named: "stop")
    let pauseImage = UIImage(named: "pause")
    let micImage = UIImage(named: "microphone")
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording"){
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as PlaySoundsViewController
            let data = sender as RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }

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
    
    @IBAction func stopRecording(sender: UIButton) {
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    func initializeNewAudioFile(){
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
    }
    
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
    
    func switchToStatusReadyForRecording(){
        recordingStatus = isReady
        recordingInProgress.text = tapToRecordText
        stopButton.hidden = true;
        micButton.setImage(micImage, forState: .Normal)
    }
    
    func switchToStatusRecording(){
        recordingStatus = isRecording
        recordingInProgress.text = recordingText
        stopButton.hidden = false;
        micButton.setImage(pauseImage, forState: .Normal)
    }
    
    func switchToStatusRecordPausing(){
        recordingStatus = isPause
        recordingInProgress.text = pauseText
        stopButton.hidden = false;
        micButton.setImage(micImage, forState: .Normal)
        currentTime = audioRecorder.currentTime
    }
    
    func switchToStatusRecordFinished(){
        recordingStatus = isFinished
        recordingInProgress.text = ""
        stopButton.hidden = false;
    }
}

