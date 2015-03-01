import UIKit

class Video: CBLModel {
   
    @NSManaged var created_at: NSDate
    @NSManaged var title: String
    @NSManaged var video_id: String
    
    var downloadTask: NSURLSessionDownloadTask?
    var isDownloading: Bool = false
    var taskIdentifier: Int?
    
    var moments: Int?
    
    init(title: String, video_id: String) {
        
        super.init(document: CouchbaseManager.shared.currentDatabase.documentWithID(video_id)!, orDatabase: nil)
        
        setValue("video", ofProperty: "type")
        self.created_at = NSDate()
        self.title = title
        self.video_id = video_id
    }

    init(document: CBLDoc) {
        super.init(document: document, orDatabase: nil)
    }
    
    class func queryVideos() -> CBLView {
        let view = CouchbaseManager.shared.currentDatabase.viewNamed("videos")
        if view.mapBlock == nil {
            view.setMapBlock({ (doc, emit) -> Void in
                if let type = doc["type"] as? String {
                    if type == "video" {
                        emit(doc["_id"]!, doc)
                    }
                }
            }, version: "1")
        }
        return view
    }
    
    class func queryVideosAndPicksNumber() -> CBLView {
        let view = CouchbaseManager.shared.currentDatabase.viewNamed("videos_with_picks")
        if view.mapBlock == nil {
            view.setMapBlock({ (doc, emit) -> Void in
                if let type = doc["type"] as? String {
                    switch type {
                    case "video":
                        emit(doc["video_id"]!, doc["title"])
                    case "pick":
                        emit(doc["video_id"]!, doc["video_title"])
                    default:
                        break
                    }
                }
            }, reduceBlock: { (keys, values, rereduce) -> AnyObject in
                let title: String = values.filter({ (element) -> Bool in
                    if let str = element as? String {
                        return true
                    }
                    return false
                }).first! as! String
                return [title, values.count]
            }, version: "8")
        }
        return view
    }
    
}
