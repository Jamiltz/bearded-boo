import UIKit
import AVKit
import AVFoundation

class EditorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var snippetButton: SnippetButton!
    
    var PlayerVC: AVPlayerViewController!
    var imageGenerator: AVAssetImageGenerator!
    
    var video: Video!
    var mp4url: NSURL!
    
    var liveQuery: CBLLiveQuery!
    var snippets: [Snippet] = []
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (object as CBLLiveQuery) == liveQuery {
            
            self.snippets = liveQuery.rows.allObjects
                .map({(row) -> Snippet in
                    let doc = (row as CBLQueryRow).document
                    return Snippet(forDocument: doc)
                })
            self.snippets.sort({ return $0.start_at < $1.start_at })

            collectionView.reloadData()
        }
    }
    
    deinit {
        liveQuery.removeObserver(self, forKeyPath: "rows")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (collectionView.collectionViewLayout as UICollectionViewFlowLayout).minimumInteritemSpacing = 0
        (collectionView.collectionViewLayout as UICollectionViewFlowLayout).itemSize = CGSizeMake(collectionView.bounds.height, collectionView.bounds.height)
        
        XCDYouTubeClient.defaultClient().getVideoWithIdentifier(video.identifier, completionHandler: { (video, error) -> Void in
            self.mp4url = (video as XCDYouTubeVideo).streamURLs[18] as NSURL
            self.startPlaying()
        })
        
        liveQuery = Snippet.querySnippetsForVideo(video.identifier).asLiveQuery()
        liveQuery.addObserver(self, forKeyPath: "rows", options: .allZeros, context: nil)
        liveQuery.run(nil)
        
        snippetButton.isActive = false
        
    }
    
    func startPlaying() {
        if let avpVC = childViewControllers.first as? AVPlayerViewController {
            PlayerVC = avpVC
            PlayerVC.player = AVPlayer(URL: mp4url)
            imageGenerator = AVAssetImageGenerator(asset: PlayerVC.player.currentItem.asset)
        }
    }
    
    @IBAction func toggleButton(sender: AnyObject) {
        let button = sender as SnippetButton
//        button.isActive = !button.isActive
        
        let cmtime = PlayerVC.player.currentTime()
        let time = CMTimeGetSeconds(cmtime)
        
        imageGenerator.generateCGImagesAsynchronouslyForTimes([NSValue(CMTime: cmtime)], completionHandler: { (requestedTime, image, actualTime, result, error) -> Void in
            if result == AVAssetImageGeneratorResult.Succeeded {
                
                // save image on the snippet object as attachment
                let uiImage = UIImage(CGImage: image)
                let data = UIImageJPEGRepresentation(uiImage, 0.5)
                
                let snippet = Snippet(annotation: "", video_id: self.video.identifier, start_at: Double(time), end_at: 0.0, image: data)
                if snippet.save(nil) {
                    println("snippet saved")
                }
                
                if let id = CouchbaseManager.shared.currentUserId {
                    if let profile = Profile.profileInDatabase(id) {
                        let notif = Notification(device_token: profile.device_token!, user_name: profile.name)
                        if notif.save(nil) {
                            println("saved notification")
                        }
                    }
                }
                
            }
        })
    }
    
    @IBAction func rewindPlayback(sender: AnyObject) {
        let time = self.PlayerVC.player.currentTime()
        let new_time = CMTimeMakeWithSeconds(CMTimeGetSeconds(time) - 5, 600)
        self.PlayerVC.player.seekToTime(new_time)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return snippets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SnippetCell", forIndexPath: indexPath) as SnippetCell
        
        let attachment: CBLAttachment? = snippets[indexPath.item].attachmentNamed("image")
        if let unwrapped = attachment {
            cell.image.image = UIImage(data: unwrapped.content)
            cell.image.contentMode = UIViewContentMode.ScaleAspectFill
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let video = snippets[indexPath.item]
        let cmtime = CMTimeMakeWithSeconds(Float64(video.start_at), 600)
        self.PlayerVC.player.seekToTime(cmtime)
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
