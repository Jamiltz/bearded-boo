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
    
    var liveQuery: CBLLiveQuery!
    var picks: [Pick] = []
    var videos: [Video] = []
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (object as CBLLiveQuery) == liveQuery {
            videos.removeAll(keepCapacity: false)
            
            for (id, count) in (liveQuery.rows.allObjects[0] as CBLQueryRow).value as [String : Int] {
                let video = Video(forDocument: kDatabase.existingDocumentWithID(id))
                video.moments = count
                videos.insert(video, atIndex: 0)
            }
            
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        liveQuery = Pick.queryUserPicks().asLiveQuery()
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
        
        cell.titleLabel.text = videos[indexPath.row].title
        cell.video_id = videos[indexPath.row].video_id
        cell.momentsLabel.text = "\(videos[indexPath.row].moments!) moments"
        
        return cell
    }
    
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
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
