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
    
    var searchTask: NSURLSessionTask?

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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        println("search")
        let searchString = searchController.searchBar.text
        
        let escapedString = searchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let url = NSURL(string: "https://www.googleapis.com/youtube/v3/search?q=\(escapedString)&key=AIzaSyBk_t-gAGOQ9A0iyAQ_XAwoTfyvLmmQRhQ&part=snippet")!
        if let searchTask = searchTask {
            searchTask.cancel()
        }
        searchTask = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data2, response, error) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                println(data2.length)
                
                let escapedString = NSString(data: data2, encoding: NSUTF8StringEncoding)!
                let str = NSString(CString: escapedString, encoding: NSNonLossyASCIIStringEncoding)
//                let parser = SBJson4Parser()
//                parser.parse(data2)
                println(escapedString)
                let data = str!.dataUsingEncoding(NSUTF16LittleEndianStringEncoding, allowLossyConversion: true)!
                
                if data.length != 0 {
                    var error: NSError?
                    let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error)
                    println(error)
                    
                    if let json = json {
                        
                        if let items = json["items"] as? [[String : AnyObject]] {
                            self.videos.removeAll(keepCapacity: false)
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
                            //                        println(self.videos.count)
                            self.tableView.reloadData()
                        }
                        
                    }
                    
                }
                
                //            controller.searchResultsTableView.reloadData()
            })
        })
        
        searchTask!.resume()
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
