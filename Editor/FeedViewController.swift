//
//  FeedViewController.swift
//  Editor
//
//  Created by James Nocentini on 12/12/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    
    var playerVC: AVPlayerViewController!
    var liveQuery: CBLLiveQuery!
    var briefs: [Brief] = []
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (object as CBLLiveQuery) == liveQuery {
            for (index, row) in enumerate(liveQuery.rows.allObjects) {
                if index >= briefs.count {
                    briefs.append(Brief(forDocument: (row as CBLQueryRow).document))
                }
            }
            
            collectionView.reloadData()
        }
    }
    
    deinit {
        liveQuery.removeObserver(self, forKeyPath: "rows")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playerVC = childViewControllers.first! as AVPlayerViewController
        
        liveQuery = Brief.queryBriefs().createQuery().asLiveQuery()
        liveQuery.addObserver(self, forKeyPath: "rows", options: .allZeros, context: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return briefs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FeedCellIdentifier", forIndexPath: indexPath) as FeedCell
        
        cell.video_id = briefs[indexPath.row].video_id
        cell.facebookUserId = briefs[indexPath.row].fb_id
        cell.nameLabel.text = briefs[indexPath.row].name
        cell.videoLabel.text = briefs[indexPath.row].caption
        cell.deleteButton.tag = indexPath.row
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let brief = briefs[indexPath.row]
        
        XCDYouTubeClient.defaultClient().getVideoWithIdentifier(brief.video_id, completionHandler: { (video, error) -> Void in
            let mp4Url = video.streamURLs[18] as NSURL
            self.playerVC.player = AVPlayer(URL: mp4Url)
            self.playerVC.player.play()
        })
    }
    
    @IBAction func deleteBrief(sender: UIButton) {
        let aBrief = briefs[sender.tag]
        if aBrief.deleteDocument(nil) {
            println("deleted brief")
            briefs.removeAtIndex(sender.tag)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
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
