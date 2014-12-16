import UIKit

class VideoDownloader: NSObject, NSURLSessionDownloadDelegate {
    var session: NSURLSession!
    
    override init() {
        let config = NSURLSessionConfiguration.backgroundSessionConfiguration("VideoSession")
        
        super.init()
        
        self.session = NSURLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    class func shared() -> VideoDownloader {
        struct Static {
            static var tokenOnce: dispatch_once_t = 0
            static var downloader: VideoDownloader?
        }
        
        dispatch_once(&Static.tokenOnce, { () -> Void in
            Static.downloader = VideoDownloader()
        })
        
        return Static.downloader!
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        let userInfo = ["progress": progress, "video_id": videoIdFromRequestURL(downloadTask.originalRequest.URL)]
        
        NSNotificationCenter.defaultCenter().postNotificationName("DownloadProgress", object: downloadTask, userInfo: userInfo)
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {

        let filePath = self.buildDownloadPath(downloadTask.originalRequest.URL)
        NSFileManager.defaultManager().copyItemAtPath(location.path!, toPath: filePath, error: nil)
        let userInfo = ["filePath": filePath, "taskIdentifier": downloadTask.taskIdentifier]
        NSNotificationCenter.defaultCenter().postNotificationName("DownloadCompletion", object: downloadTask, userInfo: userInfo)
        
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if appDelegate.backgroundSessionCompletionHandler != nil {
            appDelegate.backgroundSessionCompletionHandler!()
            appDelegate.backgroundSessionCompletionHandler = nil
        }
    }
    
    func buildDownloadPath(url: NSURL) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docsPath = paths[0].stringByAppendingPathComponent("Videos")
        
        NSFileManager.defaultManager().createDirectoryAtPath(docsPath, withIntermediateDirectories: false, attributes: nil, error: nil)
        
        let stringURL = url.absoluteString!
        let count = countElements(stringURL)
        let video_id = stringURL[advance(stringURL.startIndex, count - 11)...advance(stringURL.startIndex, count - 1)]
        
        let newFileName = video_id
        
        return docsPath.stringByAppendingPathComponent("\(newFileName).mp4")
    }
    
    func videoIsOnDisk(video_id: String) -> (isLocal: Bool, path: String) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let docsPath = paths[0].stringByAppendingPathComponent("Videos")
        let videoPath = docsPath.stringByAppendingPathComponent("\(video_id).mp4")
        return (NSFileManager.defaultManager().fileExistsAtPath(videoPath), videoPath)
    }
    
    func videoIdFromRequestURL(url: NSURL) -> String {
        let stringURL = url.absoluteString!
        let count = countElements(stringURL)
        let video_id = stringURL[advance(stringURL.startIndex, count - 11)...advance(stringURL.startIndex, count - 1)]
        return video_id
    }
    
}