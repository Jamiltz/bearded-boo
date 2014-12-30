//
//  YouTubeViewController.swift
//  Editor
//
//  Created by James Nocentini on 27/12/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var videos: [YouTubeVideo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSURL(string: "https://www.googleapis.com/youtube/v3/search?q=ios+swift&key=AIzaSyBk_t-gAGOQ9A0iyAQ_XAwoTfyvLmmQRhQ&part=snippet")!
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        // make search request to YouTube
        let escapedString = searchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let url = NSURL(string: "https://www.googleapis.com/youtube/v3/search?q=\(escapedString)&key=AIzaSyBk_t-gAGOQ9A0iyAQ_XAwoTfyvLmmQRhQ&part=snippet")!
        let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            let json: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)!
//            controller.searchResultsTableView.reloadData()
            if let items = json["items"] as? [[String : AnyObject]] {
                self.videos.removeAll(keepCapacity: false)
                self.tableView.reloadData()
                for item in items {
                    var video_id: String
                    var title: String
                    if let id = item["id"] as? [String : AnyObject] {
                        video_id = id["videoId"] as String
                        
                        if let snippet = item["snippet"] as? [String : AnyObject] {
                            title = snippet["title"] as String
                            
                            let video = YouTubeVideo(video_id: video_id, title: title)
                            self.videos.append(video)
                        }
                    }
                }
                println(self.videos.count)
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.tableView.reloadData()
                })
            }
        })
        task.resume()
        
        return false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCellId", forIndexPath: indexPath) as SearchResultCell
        
        cell.titleLabel.text = videos[indexPath.row].title
        
        return cell
    }
    
    @IBAction func doneButton() {
        dismissViewControllerAnimated(true, completion: nil)
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
