import UIKit
import AVKit
import AVFoundation

class EditorViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var SideBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet var sidebarRightConstraint: NSLayoutConstraint!
    @IBOutlet var hashtagTextfield: UITextField!
    @IBOutlet var playerView: UIView!
    @IBOutlet var thumbnailView: UIImageView!
    
    var PlayerVC: AVPlayerViewController!
    var imageGenerator: AVAssetImageGenerator!
    
    var video: Video!
    var mp4url: NSURL!
    
    var liveQuery: CBLLiveQuery!
    var snippets: [Snippet] = []
    
    var sidebarOpened: Bool = false
    
    deinit {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        XCDYouTubeClient.defaultClient().getVideoWithIdentifier(video.identifier, completionHandler: { (video, error) -> Void in
            self.mp4url = (video as XCDYouTubeVideo).streamURLs[18] as NSURL
            self.startPlaying()
        })

        sidebarRightConstraint.constant = -132

        hashtagTextfield.returnKeyType = UIReturnKeyType.Done
    }
    
    func dismissKeyboard() {
        hashtagTextfield.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        hashtagTextfield.resignFirstResponder()
        return false
    }
    
    func startPlaying() {
        if let avpVC = childViewControllers.first as? AVPlayerViewController {
            PlayerVC = avpVC
            PlayerVC.player = AVPlayer(URL: mp4url)
            imageGenerator = AVAssetImageGenerator(asset: PlayerVC.player.currentItem.asset)
        }
    }
    
    @IBAction func toggleSidebar(sender: AnyObject) {
        if sidebarOpened {
            animateSidebarWidthConstraint(-132)
        } else {
            animateSidebarWidthConstraint(-16)
        }
        sidebarOpened = !sidebarOpened
    }
    
    func animateSidebarWidthConstraint(constant: Int) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.sidebarRightConstraint.constant = CGFloat(constant)
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func toggleButton(sender: AnyObject) {
//        let button = sender as SnippetButton
//        button.isActive = !button.isActive
        
        let cmtime = PlayerVC.player.currentTime()
        let time = CMTimeGetSeconds(cmtime)
        
        imageGenerator.generateCGImagesAsynchronouslyForTimes([NSValue(CMTime: cmtime)], completionHandler: { (requestedTime, image, actualTime, result, error) -> Void in
            if result == AVAssetImageGeneratorResult.Succeeded {
                
                // save image on the snippet object as attachment
                let uiImage = UIImage(CGImage: image)
                let data = UIImageJPEGRepresentation(uiImage, 0.5)
                self.thumbnailView.image = uiImage
                
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

    
    @IBAction func saveSnippet(sender: AnyObject) {
        let button = sender as UIButton
        button.setTitle("Saved!", forState: .Normal)
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
