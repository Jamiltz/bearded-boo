//
//  EditPicksViewController.swift
//  Editor
//
//  Created by James Nocentini on 24/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class EditPicksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var slider: NMRangeSlider!
    @IBOutlet var lowerLabel: UILabel!
    @IBOutlet var upperLabel: UILabel!
    @IBOutlet var editSliderControls: UIView!
    @IBOutlet var editTopControls: UIView!
    
    var video_id: String = ""
    var playerVC: AVPlayerViewController!
    var alertView: UIAlertView!
    var liveQuery: CBLLiveQuery!
    var picks: [Pick] = []
    
    var oldLowerValue: Float = 0.0
    var oldUpperValue: Float = 0.0
    
    var currentTime: CMTime = kCMTimeZero
    var isEditingMode: Bool = false
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (object as CBLLiveQuery) == liveQuery {
            picks.removeAll(keepCapacity: false)
            
            for (index, row) in enumerate(liveQuery.rows.allObjects) {
                picks.append(Pick(forDocument: (row as CBLQueryRow).document))
            }
            
            picks.sort({ (a, b) -> Bool in
                return a.end_at < b.end_at
            })
            
            collectionView.reloadData()
        }
    }
    
    deinit {
        liveQuery.removeObserver(self, forKeyPath: "rows")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        playerVC = childViewControllers.first! as AVPlayerViewController
        
        let file = VideoDownloader.shared().videoIsOnDisk(video_id)
        
        if file.isLocal {
            playerVC.player = AVPlayer(URL: NSURL(fileURLWithPath: file.path)!)
        } else {
            // FATAL :: http call crashing app when offline
            XCDYouTubeClient.defaultClient().getVideoWithIdentifier(video_id, completionHandler: { (video, error) -> Void in
                let mp4Url = video.streamURLs[18] as NSURL
                self.playerVC.player = AVPlayer(URL: mp4Url)
            })
        }
        
        liveQuery = Pick.querySnippetsForVideo(video_id).asLiveQuery()
        liveQuery.addObserver(self, forKeyPath: "rows", options: .allZeros, context: nil)
        
        alertView = UIAlertView(title: "Publish your Picks", message: "The selected picks (in green) will appear in the news feed. Provide a descriptive subject:", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Confirm")
        alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        navigationController?.interactivePopGestureRecognizer.delegate = self
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
        return false;
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.topItem?.title = "Edit Picks"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "showConfirmMessage:")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func showEditMode() {
        currentTime = playerVC.player.currentTime()
        
        editTopControls.transform = CGAffineTransformMakeTranslation(0, 0)
        editSliderControls.transform = CGAffineTransformMakeTranslation(0, 0)
        
        spring(0.5, { () -> Void in
            self.editTopControls.transform = CGAffineTransformMakeTranslation(0, 40)
            self.editSliderControls.transform = CGAffineTransformMakeTranslation(0, 100)
        })
    }
    
    func hideEditMode() {
        playerVC.player.currentItem.forwardPlaybackEndTime = kCMTimeInvalid
        playerVC.player.seekToTime(currentTime)
        
        spring(0.5, { () -> Void in
            self.editTopControls.transform = CGAffineTransformMakeTranslation(0, 0)
            self.editSliderControls.transform = CGAffineTransformMakeTranslation(0, 0)
        })
    }
    
    func showConfirmMessage(sender: AnyObject) {
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if let text = alertView.textFieldAtIndex(0)?.text {
                publishSelectedPicks(text)
            }
        }
    }
    
    func publishSelectedPicks(title: String) {
        
        let selectedPicks = picks.filter { (pick) -> Bool in
            if pick.highlight == true {
                return true
            }
            return false
        }
        
        let profile = Profile.profileInDatabase(CouchbaseManager.shared.currentUserId!)!
        
        var length: Double = 0.0
        for (index, pick) in enumerate(selectedPicks) {
            if pick.start_at == 0.0 {
                length += 12.0
            } else {
                length += (pick.end_at - pick.start_at)
            }
        }
        
        let brief = Brief(video_id: video_id, updated_at: NSDate(), picks: selectedPicks, fb_id: profile.fb_id, name: profile.name, caption: title, length: Int(length))
        if brief.save(nil) {
            println("saved new brief")
        }
        
        // check if a brief already exists for this video_id
//        if let brief = Brief.briefForVideoInDatabase(video_id) {
//            brief.updated_at = NSDate()
//            brief.status = "publishing"
//            if brief.save(nil) {
//                println("updated brief")
//            }
//        } else {
//            let brief = Brief(video_id: video_id, updated_at: NSDate(), status: "publishing", link: "")
//            if brief.save(nil) {
//                println("saved new brief")
//            }
//        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func rewindPlayback(sender: AnyObject) {
        let time = playerVC.player.currentTime()
        let new_time = CMTimeMakeWithSeconds(CMTimeGetSeconds(time) - 5, 600)
        playerVC.player.seekToTime(new_time)
    }
    
    @IBAction func savePick(sender: AnyObject) {
        let cmtime = playerVC.player.currentTime()
        let seconds = Double(CMTimeGetSeconds(cmtime))
        
        let pick = Pick(video_id: video_id, start_at: nil, end_at: seconds)
        if pick.save(nil) {
            println("saved pick")
        }
    }
    
    @IBAction func forwardPlayback(sender: AnyObject) {
        let time = playerVC.player.currentTime()
        let new_time = CMTimeMakeWithSeconds(CMTimeGetSeconds(time) + 5, 600)
        playerVC.player.seekToTime(new_time)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        println("background")
        
        var delta: Int64 = 1 * Int64(NSEC_PER_MSEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, delta)
        
        if playerVC.player.rate == 1.0 {
            dispatch_after(time, dispatch_get_main_queue(), {
                self.playerVC.player.play()
            })
        }
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picks.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EditPicksCellIdentifier", forIndexPath: indexPath) as EditPicksCell
        
        cell.indexLabel.text = "\(indexPath.row)"
        cell.highlight = picks[indexPath.row].highlight
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if !isEditingMode {
            showEditMode()
            isEditingMode = true
        }
        
        let pick = picks[indexPath.item]
        
        setSliderForPick(pick)
        
        playerVC.player.currentItem.forwardPlaybackEndTime = kCMTimeInvalid
        // set up the playerVC to this pick and start playing
        var start_cmtime: CMTime
        if pick.start_at == 0.0 {
            start_cmtime = CMTimeMakeWithSeconds(Float64(pick.end_at - 12), 600)
        } else {
            start_cmtime = CMTimeMakeWithSeconds(Float64(pick.start_at), 600)
        }
        playerVC.player.seekToTime(start_cmtime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        let end_cmtime = CMTimeMakeWithSeconds(Float64(pick.end_at), 600)
        playerVC.player.currentItem.forwardPlaybackEndTime = end_cmtime
        playerVC.player.play()
    }
    
    @IBAction func panGesture(sender: UIButton) {
        if isEditingMode {
            hideEditMode()
            if let indexPaths = collectionView.indexPathsForSelectedItems() as? [NSIndexPath] {
                collectionView.deselectItemAtIndexPath(indexPaths[0], animated: true)
            }
            isEditingMode = false
        }
    }
    
    @IBAction func doubleTappedCell(sender: AnyObject) {
        let tappedPoint = sender.locationInView(collectionView)
        let tappedCellPath = collectionView.indexPathForItemAtPoint(tappedPoint)
        
        if let path = tappedCellPath {
            let pick = picks[path.item]
            pick.highlight = !pick.highlight
            if pick.save(nil) {
                println("updated pick")
            }
        }
    }
    
    @IBAction func sliderTouchUp(sender: NMRangeSlider) {
        if slider.lowerValue != oldLowerValue {
            replayPickWithSliderValues(self)
        }
        
        if slider.upperValue != oldUpperValue {
            replayPickFromEnd()
        }
        
        oldLowerValue = slider.lowerValue
        oldUpperValue = slider.upperValue
    }
    
    @IBAction func sliderValuesChanged(sender: NMRangeSlider) {
        updateSliderLabels()
    }
    
    @IBAction func savePick() {
        if let indexPaths = collectionView.indexPathsForSelectedItems() as? [NSIndexPath] {
            let pick = picks[indexPaths[0].item]
            pick.start_at = Double(slider.lowerValue)
            pick.end_at = Double(slider.upperValue)
            if pick.save(nil) {
                println("updated pick")
            }
        }
    }
    
    @IBAction func replayPickWithSliderValues(sender: AnyObject) {
        let start_cmtime = CMTimeMakeWithSeconds(Float64(slider.lowerValue), 600)
        playerVC.player.seekToTime(start_cmtime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
        let end_cmtime = CMTimeMakeWithSeconds(Float64(slider.upperValue), 600)
        playerVC.player.currentItem.forwardPlaybackEndTime = end_cmtime
        
        playerVC.player.play()
    }
    
    func replayPickFromEnd() {
        let start_cmtime = CMTimeMakeWithSeconds(Float64(slider.upperValue - 3), 600)
        playerVC.player.seekToTime(start_cmtime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
        let end_cmtime = CMTimeMakeWithSeconds(Float64(slider.upperValue), 600)
        playerVC.player.currentItem.forwardPlaybackEndTime = end_cmtime
        
        playerVC.player.play()
    }
    
    @IBAction func deletePick() {
        if let indexPaths = collectionView.indexPathsForSelectedItems() as? [NSIndexPath] {
            let pick = picks[indexPaths[0].item]
            if pick.deleteDocument(nil) {
                println("deleted pick")
                picks.removeAtIndex(indexPaths[0].item)
            }
        }
    }
    
    func setSliderForPick(pick: Pick) {
        slider.minimumValue = 0
        slider.lowerValue = 0
        slider.upperValue = 1
        slider.maximumValue = 1
        
        slider.maximumValue = Float(pick.end_at + 3)
        slider.upperValue = Float(pick.end_at)
        if pick.start_at == 0.0 {
            slider.lowerValue = Float(pick.end_at - 12)
            slider.minimumValue = Float(pick.end_at - 15)
        } else {
            slider.lowerValue = Float(pick.start_at)
            slider.minimumValue = Float(pick.start_at - 3)
        }
        
        var delta: Int64 = 0 * Int64(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, delta)
        
        dispatch_after(time, dispatch_get_main_queue(), {
            self.updateSliderLabels()
        });
        
        oldLowerValue = slider.lowerValue
        oldUpperValue = slider.upperValue
    }
    
    func updateSliderLabels() {
        // get the center point of the slider handles and use this to arrange the labels
        var lowerCenter: CGPoint = CGPoint()
        lowerCenter.x = slider.lowerCenter.x + slider.frame.origin.x
        lowerCenter.y = slider.center.y - 50
        lowerLabel.center = lowerCenter
        lowerLabel.text = secondsConvertToTimeFormat(slider.lowerValue)
        
        var upperCenter: CGPoint = CGPoint()
        upperCenter.x = slider.upperCenter.x + slider.frame.origin.x
        upperCenter.y = slider.center.y - 50
        upperLabel.center = upperCenter
        upperLabel.text = secondsConvertToTimeFormat(slider.upperValue)
    }
    
    func secondsConvertToTimeFormat(total: Float) -> String {
        let seconds = total % 60
        let minutes = (Int(total) / 60) % 60
        let hours = Int(total) / 3600

        return String(format: "%02d:%02d:%02f", arguments: [hours, minutes, seconds])
    }
    
}
