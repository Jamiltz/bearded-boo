import UIKit

class VideoViewController: UIViewController, UITableViewDataSource {
    
    
    @IBOutlet var formView: UIView!
    @IBOutlet var formTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var videoTextField: UITextField!
    
    var liveQuery: CBLLiveQuery!
    var videos: [Video] = []
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (object as CBLLiveQuery) == liveQuery {
            
            for (index, row) in enumerate(liveQuery.rows.allObjects) {
                if index > videos.count {
                    videos.insert(Video(forDocument: (row as CBLQueryRow).document), atIndex: 0)
                }
            }
            
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent

        Video.queryVideos()
        liveQuery = kDatabase.viewNamed("videos").createQuery().asLiveQuery()
        liveQuery.addObserver(self, forKeyPath: "rows", options: .allZeros, context: nil)
        
        navBarForLoggedOutUser()
        formTopLayoutConstraint.constant = -90
    }
    
    override func viewDidAppear(animated: Bool) { // to update the nav bar every time it appears on screen
        super.viewDidAppear(animated)
        
        navBarForLoggedOutUser()
    }
    
    func navBarForLoggedOutUser() {
//        if let userId = CouchbaseManager.shared.currentUserId {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "showHeaderView:")
        
//        } else {
        
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginUser(sender: AnyObject) {
        
    }
    
    @IBAction func saveVideo(sender: AnyObject) {
        let urlOptional = NSURL(string: videoTextField.text)
        if let url = urlOptional {
            let query = url.query!
            let video_id = query[advance(query.startIndex, 2)...advance(query.startIndex, 12)]
            XCDYouTubeClient.defaultClient().getVideoWithIdentifier(video_id, completionHandler: { (video, error) -> Void in
                if video != nil {
                    var aVideo = Video(url: url, title: video.title, identifier: video.identifier, image_url: video.mediumThumbnailURL) as Video
                    if aVideo.save(nil) {
                        println("saved new video")
                    }
                }
            })
            
        }
    }
    
    
    func showHeaderView(sender: AnyObject) {
        if (navigationItem.rightBarButtonItem?.tintColor != UIColor.redColor()) {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.redColor()
            animateFormTopConstraint(0)
        } else {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.blueColor()
            animateFormTopConstraint(-90)
        }
        
    }
    
    func animateFormTopConstraint(constant: Int) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.formTopLayoutConstraint.constant = CGFloat(constant)
            self.view.layoutIfNeeded()
        })
    }

    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as VideoTableCell

        cell.title.text = videos[indexPath.row].title
        cell.thumbnail_url = videos[indexPath.row].image_url.absoluteString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.performSegueWithIdentifier("VideoSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "VideosToEditor" {
            let vc = segue.destinationViewController as EditorViewController
            let video = videos[tableView.indexPathForSelectedRow()!.row]
            vc.video = video
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
