import UIKit
import AVKit
import AVFoundation

class EditorViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var sidebarRightConstraint: NSLayoutConstraint!
    @IBOutlet var rangesliderBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet var hashtagTextfield: UITextField!
    @IBOutlet var playerView: UIView!
    @IBOutlet var thumbnailView: UIImageView!
    
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    
    var PlayerVC: AVPlayerViewController!
    var imageGenerator: AVAssetImageGenerator!
    
    @IBOutlet var sliderView: NMRangeSlider!
    
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
        rangesliderBottomConstraint.constant = -40

        hashtagTextfield.returnKeyType = UIReturnKeyType.Done
        
        navigationController?.interactivePopGestureRecognizer.delegate = self
        
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
        return false;
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
            PlayerVC.player.currentItem.forwardPlaybackEndTime = kCMTimeInvalid
            thumbnailView.image = nil
            
            animateSidebarWidthConstraint(-132)
            animateRangesliderBottomConstraint(-40)
        } else {
            
            let cmtime = PlayerVC.player.currentItem.currentTime()
            let seconds = Float(CMTimeGetSeconds(cmtime))
            
            if seconds < sliderView.maximumValue {
                sliderView.minimumValue = seconds - 3
                sliderView.lowerValue = seconds + 0
                sliderView.maximumValue = seconds + 9
                sliderView.upperValue = seconds + 6
            } else {
                sliderView.maximumValue = seconds + 9
                sliderView.upperValue = seconds + 6
                sliderView.minimumValue = seconds - 3
                sliderView.lowerValue = seconds + 0
            }
            
            sliderValueChanged(sliderView)
            
            animateSidebarWidthConstraint(-16)
            animateRangesliderBottomConstraint(0)
        }
        sidebarOpened = !sidebarOpened
    }
    
    func animateSidebarWidthConstraint(constant: Int) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.sidebarRightConstraint.constant = CGFloat(constant)
            self.view.layoutIfNeeded()
        })
    }
    
    func animateRangesliderBottomConstraint(constant: Int) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.rangesliderBottomConstraint.constant = CGFloat(constant)
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func rewindPlayback(sender: AnyObject) {
        let time = self.PlayerVC.player.currentTime()
        let new_time = CMTimeMakeWithSeconds(CMTimeGetSeconds(time) - 5, 600)
        self.PlayerVC.player.seekToTime(new_time)
    }

    @IBAction func sliderValueChanged(sender: AnyObject) {
        startTimeLabel.text = secondsConvertToTimeFormat(Int(sliderView.lowerValue))
        endTimeLabel.text = secondsConvertToTimeFormat(Int(sliderView.upperValue))
    }
    
    @IBAction func replaySnippet(sender: AnyObject) {
        let start_cmtime = CMTimeMakeWithSeconds(Float64(sliderView.lowerValue), 600)
        PlayerVC.player.seekToTime(start_cmtime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        
        let end_cmtime = CMTimeMakeWithSeconds(Float64(sliderView.upperValue), 600)
        PlayerVC.player.currentItem.forwardPlaybackEndTime = end_cmtime
        
        PlayerVC.player.play()
    }
    
    
    @IBAction func saveSnippet(sender: AnyObject) {
        let button = sender as UIButton
        
        //        let button = sender as SnippetButton
        //        button.isActive = !button.isActive
        
        let cmtime = CMTimeMakeWithSeconds(Float64(sliderView.lowerValue), 600)
        imageGenerator.generateCGImagesAsynchronouslyForTimes([NSValue(CMTime: cmtime)], completionHandler: { (requestedTime, image, actualTime, result, error) -> Void in
            if result == AVAssetImageGeneratorResult.Succeeded {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    // save image on the snippet object as attachment
                    if image != nil {
                        
                        let uiImage = UIImage(CGImage: image)
                        let data = UIImageJPEGRepresentation(uiImage, CGFloat(0.5))
                        
                        self.thumbnailView.image = uiImage
                        
                        let start_time = Double(self.sliderView.lowerValue)
                        let end_time = Double(self.sliderView.upperValue)
                        let snippet = Snippet(annotation: self.hashtagTextfield.text, video_id: self.video.identifier, start_at: start_time, end_at: end_time, image: data)
                        if snippet.save(nil) {
                            println("snippet saved")
                            self.toggleSidebar(self)
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
        })
    }
    
    func secondsConvertToTimeFormat(total: Int) -> String {
        let seconds = total % 60
        let minutes = (total / 60) % 60
        let hours = total / 3600
        
        return String(format: "%02d:%02d:%02d", arguments: [hours, minutes, seconds])
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
