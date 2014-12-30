import UIKit

class YouTubeVideo: NSObject {
   
    let video_id: String
    let title: String

    init(video_id: String, title: String) {
        self.video_id = video_id
        self.title = title
        
        super.init()
    }
    
}
