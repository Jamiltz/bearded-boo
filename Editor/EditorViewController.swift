import UIKit
import AVKit
import AVFoundation

class EditorViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var playerView: UIView!
    
    var PlayerVC: AVPlayerViewController!
    var imageGenerator: AVAssetImageGenerator!
    
    var video: Video!
    var mp4url: NSURL!
    
    var liveQuery: CBLLiveQuery!
    var snippets: [Pick] = []
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let file = VideoDownloader.shared().videoIsOnDisk(video.video_id)
        
        if file.isLocal {
            self.mp4url = NSURL(fileURLWithPath: file.path)
            self.startPlaying()
        } else {
            XCDYouTubeClient.defaultClient().getVideoWithIdentifier(video.video_id, completionHandler: { (video, error) -> Void in
                self.mp4url = (video as XCDYouTubeVideo).streamURLs[18] as NSURL
                self.startPlaying()
            })
        }
        
        navigationController?.interactivePopGestureRecognizer.delegate = self
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
        return false;
    }
    
    func startPlaying() {
        if let avpVC = childViewControllers.first as? AVPlayerViewController {
            PlayerVC = avpVC
            PlayerVC.player = AVPlayer(URL: mp4url)
            imageGenerator = AVAssetImageGenerator(asset: PlayerVC.player.currentItem.asset)
        }
    }
    
    @IBAction func rewindPlayback(sender: AnyObject) {
        let time = self.PlayerVC.player.currentTime()
        let new_time = CMTimeMakeWithSeconds(CMTimeGetSeconds(time) - 5, 600)
        self.PlayerVC.player.seekToTime(new_time)
    }
    
    @IBAction func savePick(sender: AnyObject) {
        let cmtime = PlayerVC.player.currentTime()
        let seconds = Double(CMTimeGetSeconds(cmtime))
        
        let pick = Pick(video_id: video.video_id, start_at: nil, end_at: seconds)
        if pick.save(nil) {
            println("saved pick")
        }
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
