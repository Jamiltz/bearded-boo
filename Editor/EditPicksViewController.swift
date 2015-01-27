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

class EditPicksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate, MGSwipeTableCellDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var slider: NMRangeSlider!
    @IBOutlet var lowerLabel: UILabel!
    @IBOutlet var upperLabel: UILabel!
    @IBOutlet var editSliderControls: UIView!
    @IBOutlet var editTopControls: UIView!
    
    var video_id: String = ""
    var video_title: String = ""
    var playerVC: AVPlayerViewController!
    var alertView: UIAlertView!
    var captionAlertView: UIAlertView!
    var liveQuery: CBLLiveQuery!
    var picks: [Pick] = []
    
    var profile: Profile {
        return Profile(document: CouchbaseManager.shared.currentDatabase.documentWithID(CouchbaseManager.shared.currentUserId))
    }
    
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
            
            let selectedIndex = tableView.indexPathForSelectedRow()
            
            tableView.reloadData()
            
            if let indexPath = selectedIndex {
                tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
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
//            XCDYouTubeClient.defaultClient().getVideoWithIdentifier(video_id, completionHandler: { (video, error) -> Void in
//                let mp4Url = video.streamURLs[18] as NSURL
//                self.playerVC.player = AVPlayer(URL: mp4Url)
//            })
        }
        
        liveQuery = Pick.querySnippetsForVideo(video_id).asLiveQuery()
        liveQuery.addObserver(self, forKeyPath: "rows", options: .allZeros, context: nil)
        
        alertView = UIAlertView(title: "Publish your Picks", message: "The selected picks (in green) will appear in the news feed. Provide a descriptive subject:", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Confirm")
        alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
        
        captionAlertView = UIAlertView(title: "Caption", message: "Give a descriptive title to this pick", delegate: self, cancelButtonTitle: "Close", otherButtonTitles: "Save")
        captionAlertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        navigationController?.interactivePopGestureRecognizer.delegate = self

    }
    
//    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
//        return false;
//    }

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
        
        
        let pick = Pick(video_id: video_id, start_at: nil, end_at: seconds, caption: "", video_title: video_title)
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(80)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return picks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("EditPicksCellIdentifier", forIndexPath: indexPath) as EditPicksCell
        let pick = picks[indexPath.row]
        
        if pick.start_at == 0.0 {
            cell.startTimeLabel.text = secondsConvertToTimeFormat(Float(pick.end_at - 12.0))
        } else {
            cell.startTimeLabel.text = secondsConvertToTimeFormat(Float(pick.start_at))
        }
//        cell.indexLabel.text = "\(indexPath.row)"
//        cell.highlight = picks[indexPath.row].highlight
        
        cell.captionLabel.text = ""
        if let caption = pick.caption {
            cell.captionLabel.text = caption
        }
        
        cell.captionLabel.sizeToFit()
        
        cell.delegate = self
        cell.leftButtons = [MGSwipeButton(title: "Publish", backgroundColor: UIColor.blueColor())]
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor.redColor())]
        
        return cell
    }
    
    func swipeTableCell(cell: MGSwipeTableCell!, tappedButtonAtIndex index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        
        if (direction == MGSwipeDirection.RightToLeft && index == 0) {
            println("delete pick")
        } else {
            println("publish pick")
            let indexPath = tableView.indexPathForCell(cell)!
            let pick = picks[indexPath.row]
            let brief = Brief(pick: pick, user: profile)
            if brief.save(nil) {
                println("brief saved")
            }
        }
        
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
//    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            let pick = picks[indexPath.row]
//            if pick.deleteDocument(nil) {
//                picks.removeAtIndex(indexPath.row)
//                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//            }
//        }
//    }
    
    @IBAction func panGesture(sender: UIButton) {
        if isEditingMode {
            hideEditMode()
            if let indexPaths = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {
                if indexPaths.count > 0 {
                    tableView.deselectRowAtIndexPath(indexPaths[0], animated: true)
                }
            }
            isEditingMode = false
        }
    }
    
    @IBAction func doubleTappedCell(sender: AnyObject) {
        let tappedPoint = sender.locationInView(tableView)
        let tappedCellPath = tableView.indexPathForRowAtPoint(tappedPoint)

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
        
        savePick()
    }
    
    @IBAction func sliderValuesChanged(sender: NMRangeSlider) {
        updateSliderLabels()
    }
    
    func savePick() {
        if let indexPaths = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {
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
    
    @IBAction func editCaption() {
        if let indexPath = tableView.indexPathForSelectedRow() {
            if let caption = picks[indexPath.row].caption {
                captionAlertView.textFieldAtIndex(0)?.text = picks[indexPath.row].caption
            }
            captionAlertView.show()
        }
    }
    
    @IBAction func deletePick() {
        if let indexPaths = tableView.indexPathsForSelectedRows() as? [NSIndexPath] {
            let pick = picks[indexPaths[0].item]
            if pick.deleteDocument(nil) {
                println("deleted pick")
                picks.removeAtIndex(indexPaths[0].item)
            }
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            if let indexPath = tableView.indexPathForSelectedRow() {
                let pick = picks[indexPath.row]
                pick.caption = captionAlertView.textFieldAtIndex(0)?.text
                if pick.save(nil) {
                    captionAlertView.textFieldAtIndex(0)?.text = ""
                    println("updated pick")
                }
            }
        }
        
        //        if buttonIndex == 1 {
        //            if let text = alertView.textFieldAtIndex(0)?.text {
        //                publishSelectedPicks(text)
        //            }
        //        }
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
