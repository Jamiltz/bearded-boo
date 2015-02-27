//
//  YouTubeViewController.swift
//  Editor
//
//  Created by James Nocentini on 27/12/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    @IBOutlet var tableView: UITableView!
    
    var videos: [YouTubeVideo] = []
    
    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSURL(string: "https://www.googleapis.com/youtube/v3/search?q=ios+swift&key=AIzaSyBk_t-gAGOQ9A0iyAQ_XAwoTfyvLmmQRhQ&part=snippet")!
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self // se we can monitor text changes + others
        
        definesPresentationContext = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {

        let searchString = searchController.searchBar.text

        if count(searchString) > 0 {
            
            let escapedString = searchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            let urlString = "https://www.googleapis.com/youtube/v3/search?q=\(escapedString)&key=AIzaSyBk_t-gAGOQ9A0iyAQ_XAwoTfyvLmmQRhQ&part=snippet&maxResults=50"
            
            JSONHTTPClient.getJSONFromURLWithString(urlString, completion: { (json, error) -> Void in
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    if let items = json["items"] as? [[String : AnyObject]] {
                        self.videos.removeAll(keepCapacity: false)
                        for item in items {
                            var video_id: String
                            var title: String
                            if let id = item["id"] as? [String : AnyObject] {
                                let id: AnyObject? = id["videoId"]
                                if let id = id as? String {
                                    video_id = "\(id)" // this is probably a bug
                                } else {
                                    video_id = ""
                                }
                                
                                if let snippet = item["snippet"] as? [String : AnyObject] {
                                    title = snippet["title"] as! String
                                    
                                    let video = YouTubeVideo(video_id: video_id, title: title)
                                    self.videos.append(video)
                                }
                            }
                        }
                        self.tableView.reloadData()
                    }
                })
                
            })
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCellId", forIndexPath: indexPath) as! SearchResultCell
        
        cell.titleLabel.text = videos[indexPath.row].title
        cell.video_id = videos[indexPath.row].video_id
        
        return cell
    }
    
    @IBAction func doneButton() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "YouTubeSearchSegue" {
            let vc = segue.destinationViewController as! EditPicksViewController
            if let indexPath = tableView.indexPathForSelectedRow() {
                let youtubeVideo = videos[indexPath.row]
                vc.video_id = youtubeVideo.video_id
                vc.video_title = youtubeVideo.title
            }
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
