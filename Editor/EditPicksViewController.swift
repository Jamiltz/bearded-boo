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

class EditPicksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var slider: NMRangeSlider!
    @IBOutlet var lowerLabel: UILabel!
    @IBOutlet var upperLabel: UILabel!
    
    var video_id: String = ""
    var playerVC: AVPlayerViewController!
    var liveQuery: CBLLiveQuery!
    var picks: [Pick] = []
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (object as CBLLiveQuery) == liveQuery {
            for (index, row) in enumerate(liveQuery.rows.allObjects) {
                if index >= picks.count {
                    picks.append(Pick(forDocument: (row as CBLQueryRow).document))
                }
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
            XCDYouTubeClient.defaultClient().getVideoWithIdentifier(video_id, completionHandler: { (video, error) -> Void in
                let mp4Url = video.streamURLs[18] as NSURL
                self.playerVC.player = AVPlayer(URL: mp4Url)
            })
        }
        
        liveQuery = Pick.querySnippetsForVideo(video_id).asLiveQuery()
        liveQuery.addObserver(self, forKeyPath: "rows", options: .allZeros, context: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.topItem?.title = "Edit Picks"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picks.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EditPicksCellIdentifier", forIndexPath: indexPath) as EditPicksCell
        
        cell.indexLabel.text = "\(indexPath.row)"
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
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
    
    @IBAction func replayPickWithSliderValues(sender: UIButton) {
        let start_cmtime = CMTimeMakeWithSeconds(Float64(slider.lowerValue), 600)
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
    
    @IBAction func publishBrief() {
        // check if a brief already exists for this video_id
        if let brief = Brief.briefForVideoInDatabase(video_id) {
            brief.updated_at = NSDate()
            brief.status = "publishing"
            if brief.save(nil) {
                println("updated brief")
            }
        } else {
            let brief = Brief(video_id: video_id, updated_at: NSDate(), status: "publishing", link: "")
            if brief.save(nil) {
                println("saved new brief")
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
        
        updateSliderLabels()
    }
    
    func updateSliderLabels() {
        // get the center point of the slider handles and use this to arrange the labels
        var lowerCenter: CGPoint = CGPoint()
        lowerCenter.x = slider.lowerCenter.x + slider.frame.origin.x
        lowerCenter.y = slider.center.y - 40
        lowerLabel.center = lowerCenter
        lowerLabel.text = secondsConvertToTimeFormat(Int(slider.lowerValue))
        
        var upperCenter: CGPoint = CGPoint()
        upperCenter.x = slider.upperCenter.x + slider.frame.origin.x
        upperCenter.y = slider.center.y - 40
        upperLabel.center = upperCenter
        upperLabel.text = secondsConvertToTimeFormat(Int(slider.upperValue))
    }
    
    func secondsConvertToTimeFormat(total: Int) -> String {
        let seconds = total % 60
        let minutes = (total / 60) % 60
        let hours = total / 3600
        
        return String(format: "%02d:%02d:%02d", arguments: [hours, minutes, seconds])
    }
    
}
