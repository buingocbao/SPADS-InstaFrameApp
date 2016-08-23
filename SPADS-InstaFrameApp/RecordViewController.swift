//
//  RecordViewController.swift
//  SPADS-InstaFrameApp
//
//  Created by BBaoBao on 6/3/15.
//  Copyright (c) 2015 buingocbao. All rights reserved.
//

import UIKit
import AVFoundation

class RecordedAudio:NSObject
{
    var title:String!
    var filePathURL:NSURL!
}

class RecordViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var btRecord: MKButton!
    @IBOutlet weak var btPlay: MKButton!
    @IBOutlet weak var btPause: MKButton!
    @IBOutlet weak var btRefresh: MKButton!
    @IBOutlet weak var btOk: MKButton!
    @IBOutlet weak var btCancel: MKButton!
    
    var audioPlayer:AVAudioPlayer!
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    var filePath:NSURL!
    var recordingName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Record config
        btRecord.maskEnabled = false
        btRecord.backgroundAniEnabled = false
        btRecord.rippleLocation = .Center
        
        // Play config
        btPlay.enabled = false
        btPlay.alpha = 0
        btPlay.maskEnabled = false
        btPlay.backgroundAniEnabled = false
        btPlay.rippleLocation = .Center
        
        // Pause config
        btPause.enabled = false
        btPause.alpha = 0
        btPause.maskEnabled = false
        btPause.backgroundAniEnabled = false
        btPause.rippleLocation = .Center
        
        // Refresh config
        btRefresh.enabled = false
        btRefresh.alpha = 0
        btRefresh.maskEnabled = false
        btRefresh.backgroundAniEnabled = false
        btRefresh.rippleLocation = .Center
        
        // Ok config
        btOk.enabled = false
        btOk.alpha = 0
        btOk.maskEnabled = false
        btOk.backgroundAniEnabled = false
        btOk.rippleLocation = .Center
        
        // Cancel config
        btCancel.enabled = false
        btCancel.alpha = 0
        btCancel.maskEnabled = false
        btCancel.backgroundAniEnabled = false
        btCancel.rippleLocation = .Center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btRecordHold(sender: AnyObject) {
        //Get the place to store the recorded file in the app's memory
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0] as! String
        
        //Name the file with date/time to be unique
        var currentDateTime=NSDate();
        var formatter = NSDateFormatter();
        formatter.dateFormat = "ddMMyyyy-HHmmss";
        recordingName = formatter.stringFromDate(currentDateTime)+".wav"
        var pathArray = [dirPath, recordingName]
        filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        //Create a session
        var session=AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord,error:nil)
        
        //Create a new audio recorder
        audioRecorder = AVAudioRecorder(URL: filePath, settings:nil, error:nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled=true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func btRecordRelease(sender: AnyObject) {
        // Stop record
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.ShowHideTransitionViews, animations: {
            // Hide Record button
            self.btRecord.enabled = false
            self.btRecord.alpha = 0
            }, completion: { finished in
                // Show play button
                self.btPlay.enabled = true
                self.btPlay.alpha = 1
                // Show 3 bottom buttons
                self.btRefresh.enabled = true
                self.btRefresh.alpha = 1
                self.btCancel.enabled = true
                self.btCancel.alpha = 1
                self.btOk.enabled = true
                self.btOk.alpha = 1
        })
    }
    
    @IBAction func btPauseEvent(sender: AnyObject) {
        if audioPlayer.playing == true {
            audioPlayer.pause()
        }
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.ShowHideTransitionViews, animations: {
            // Hide pause button
            self.btPause.enabled = false
            self.btPause.alpha = 0
            }, completion: { finished in
                // Show play button
                self.btPlay.enabled = true
                self.btPlay.alpha = 1
        })
    }
    
    @IBAction func btPlayEvent(sender: AnyObject) {
        if let fileUrl = filePath {
            var alertSound = fileUrl
            println(fileUrl)
            
            var error:NSError?
            audioPlayer = AVAudioPlayer(contentsOfURL: alertSound, error: &error)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            audioPlayer.numberOfLoops = -1
        } else {
            println("file path is incorrect");
        }
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.ShowHideTransitionViews, animations: {
            // Hide play button
            self.btPlay.enabled = false
            self.btPlay.alpha = 0
            }, completion: { finished in
                // Show pause button
                self.btPause.enabled = true
                self.btPause.alpha = 1
        })
    }
    
    @IBAction func btRefreshEvent(sender: AnyObject) {
        // Stop player
        if audioPlayer.playing == true {
            audioPlayer.stop()
        }
        // remove the deleted item from the model
        NSFileManager.defaultManager().removeItemAtURL(filePath, error: nil)
        
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.ShowHideTransitionViews, animations: {
            // Hide all buttons
            self.btPause.enabled = false
            self.btPause.alpha = 0
            self.btPlay.enabled = false
            self.btPlay.alpha = 0
            self.btRefresh.enabled = false
            self.btRefresh.alpha = 0
            self.btOk.enabled = false
            self.btOk.alpha = 0
            self.btCancel.enabled = false
            self.btCancel.alpha = 0
            }, completion: { finished in
                // Show pause button
                self.btRecord.enabled = true
                self.btRecord.alpha = 1
        })
    }
    
    
    @IBAction func btCheckEvent(sender: AnyObject) {
        // Stop player
        //if audioPlayer.playing == true {
            //audioPlayer.stop()
        //}
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btCancelEvent(sender: AnyObject) {
        // Stop player
        //if audioPlayer.playing == true {
            //audioPlayer.stop()
        //}
        NSFileManager.defaultManager().removeItemAtURL(filePath, error: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
        println("Deleted")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if(flag)
        {
            //Store in Model
            recordedAudio=RecordedAudio()
            recordedAudio.filePathURL=recorder.url
            recordedAudio.title=recorder.url.lastPathComponent
            //Segway once we've finished processing the audio
        }
        else
        {
            println("recording not successful")
        }
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
