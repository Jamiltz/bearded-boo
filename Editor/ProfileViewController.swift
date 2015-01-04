//
//  ProfileViewController.swift
//  Editor
//
//  Created by James Nocentini on 21/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource {

    @IBOutlet var backgroundMaskView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var popoverView: UIView!
    @IBOutlet var maskButton: UIButton!
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    var liveQuery: CBLLiveQuery!
    var picks: [Pick] = []
    var videos: [YouTubeVideo] = []
    
    var facebookUserId: String? {
        didSet {
            if let id = facebookUserId {
                let url = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")
                thumbnailImageView.sd_setImageWithURL(url)
                backgroundImageView.sd_setImageWithURL(url)
            }
        }
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (object as CBLLiveQuery) == liveQuery {
            
            videos.removeAll(keepCapacity: false)

            if liveQuery.rows.allObjects.count > 0 {
                for (index, row) in enumerate(liveQuery.rows.allObjects) {
                    let row = row as CBLQueryRow
                    let video = YouTubeVideo(video_id: row.key as String, title: row.value[0]! as String)
                    video.moments = row.value[1] as? Int
                    videos.insert(video, atIndex: 0)
                }
                tableView.reloadData()
            }
            
        }
    }
    
    deinit {
        liveQuery.removeObserver(self, forKeyPath: "rows")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let profile = Profile.profileInDatabase(CouchbaseManager.shared.currentUserId!)
        facebookUserId = profile?.fb_id
        nameLabel.text = profile?.name
        
        liveQuery = Video.queryVideosAndPicksNumber().createQuery().asLiveQuery()
        liveQuery.groupLevel = 1
        liveQuery.addObserver(self, forKeyPath: "rows", options: .allZeros, context: nil)

        insertBlurView(backgroundMaskView, UIBlurEffectStyle.Dark)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow() {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Picks"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyPicksCellIdentifier", forIndexPath: indexPath) as MyPicksCell
        let video = videos[indexPath.row]
        
        cell.titleLabel.text = videos[indexPath.row].title
        cell.video_id = videos[indexPath.row].video_id
        cell.momentsLabel.text = "\(videos[indexPath.row].moments!) moments"
        cell.downloadButton.tag = indexPath.row
        
        if video.isDownloading { // if the video is downloading show the progress bar
            println("yep")
            cell.downloadButton.hidden = true
            cell.circularProgressView.hidden = false
        }
        
        
        let file = VideoDownloader.shared().videoIsOnDisk(video.video_id)
        if file.isLocal { // if the file exists locally hide the progress bar and download button
            cell.downloadButton.hidden = true
            cell.circularProgressView.hidden = true
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            let video = videos[indexPath.row]
//            if video.deleteDocument(nil) {
//                videos.removeAtIndex(indexPath.row)
//                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//            }
//        }
    }
    
    @IBAction func startDownload(sender: UIButton) {
        
        let aVideo = videos[sender.tag]
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as MyPicksCell? {
            XCDYouTubeClient.defaultClient().getVideoWithIdentifier(aVideo.video_id, completionHandler: { (video, error) -> Void in
                let mp4Url = (video as XCDYouTubeVideo).streamURLs[18] as NSURL
                let url = NSURL(string: "\(mp4Url.absoluteString!)&\(aVideo.video_id)")!
                
                self.createDownloadTask(url, video: aVideo)
                let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            })
        }
        
    }
    
    func createDownloadTask(url: NSURL, video: YouTubeVideo) {
        let task = VideoDownloader.shared().session.downloadTaskWithURL(url)
        video.isDownloading = true
        video.downloadTask = task
        video.taskIdentifier = task.taskIdentifier
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateProgress:", name: "DownloadProgress", object: task)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishDownload:", name: "DownloadCompletion", object: task)
        
        task.resume()
    }
    
    func updateProgress(notification: NSNotification) {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            let video_id = notification.userInfo!["video_id"]! as String
            
            var found: Int?
            for (index, video) in enumerate(self.videos) {
                if video.video_id == video_id {
                    found = index
                }
            }
            
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: found!, inSection: 0)) as MyPicksCell? {
                cell.circularProgressView.setProgress(Float(notification.userInfo!["progress"]! as Double), animated: true)
            }
        }
    }
    
    func finishDownload(notification: NSNotification) {
        println(notification.userInfo!["filePath"])
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        for (index, video) in enumerate(self.videos) {
            if let taskIdentifier = video.taskIdentifier {
                if taskIdentifier == notification.userInfo!["taskIdentifier"] as Int {
                    println("found")
                    video.downloadTask = nil
                    video.isDownloading = false
                    video.taskIdentifier = nil
                    videos[index] = video
                    
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                }
            }
        }
    }
    
    @IBAction func stopDownload(sender: UIButton) {
        
        let cell = sender.superview!.superview! as MyPicksCell
        if let indexPath = tableView.indexPathForCell(cell) {
            let aVideo = videos[indexPath.row]
            aVideo.downloadTask!.cancel()
            aVideo.isDownloading = false
            aVideo.taskIdentifier = nil
            
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            cell.circularProgressView.setProgress(0.0, animated: false)
        }
        
    }
    
    // ====
    
    @IBAction func userButtonDidPress(sender: UIButton) {
        popoverView.hidden = false
        
        let scale = CGAffineTransformMakeScale(0.3, 0.3)
        let translate = CGAffineTransformMakeTranslation(50, -50)
        popoverView.transform = CGAffineTransformConcat(scale, translate)
        popoverView.alpha = 0
        
        showMask()
        
        spring(0.5) {
            let scale = CGAffineTransformMakeScale(1, 1)
            let translate = CGAffineTransformMakeTranslation(0, 0)
            self.popoverView.transform = CGAffineTransformConcat(scale, translate)
            self.popoverView.alpha = 1
        }
    }
    
    @IBAction func logout(sender: UIButton) {
        FBSession.activeSession().closeAndClearTokenInformation()
        FBSession.activeSession().close()
        FBSession.setActiveSession(nil)
        CouchbaseManager.shared.currentUserId = nil
        CouchbaseManager.shared.stopReplication()
        CouchbaseManager.shared.currentDatabase = nil
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func hidePopover() {
        spring(0.5) {
            self.popoverView.hidden = true
        }
    }
    
    func showMask() {
        self.maskButton.hidden = false
        self.maskButton.alpha = 0
        spring(0.5) {
            self.maskButton.alpha = 1
        }
    }
    
    @IBAction func maskButtonDidPress(sender: UIButton) {
        spring(0.5) {
            self.maskButton.alpha = 0
        }
        hidePopover()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditPicksSegue" {
            let vc = segue.destinationViewController as EditPicksViewController
            vc.video_id = (sender as MyPicksCell).video_id
            if let indexPath = tableView.indexPathForSelectedRow() {
                let video = videos[indexPath.row]
                vc.video_id = video.video_id
                vc.video_title = video.title
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
