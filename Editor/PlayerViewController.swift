import UIKit
import AVKit
import AVFoundation

class PlayerViewController: AVPlayerViewController {
    
    var currentIndex: Int = 0
    var picks: [Pick] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadContent(picks: [Pick]) {
        
        self.picks = picks
        
        // listener for end event
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFinishPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        playFirstPick(picks[0])
    }
    
    func playFirstPick(pick: Pick) {
        var start_cmtime: CMTime
        if pick.start_at == 0.0 {
            start_cmtime = CMTimeMakeWithSeconds(Float64(pick.end_at - 12), 600)
        } else {
            start_cmtime = CMTimeMakeWithSeconds(Float64(pick.start_at), 600)
        }
        player.seekToTime(start_cmtime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        let end_cmtime = CMTimeMakeWithSeconds(Float64(pick.end_at), 600)
        player.currentItem.forwardPlaybackEndTime = end_cmtime
        player.play()
    }
    
    func didFinishPlaying(notification: NSNotification) {
        println("end")
        if currentIndex < picks.count - 1 {
            currentIndex++
            playFirstPick(picks[currentIndex])
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
