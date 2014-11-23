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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
