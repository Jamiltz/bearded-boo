import UIKit

class Video: CBLModel {
   
    @NSManaged var created_at: NSDate
    @NSManaged var title: String
    @NSManaged var video_id: String
    
    var moments: Int?
    
    init(title: String, video_id: String) {
        
        super.init(document: CouchbaseManager.shared.currentDatabase.documentWithID(video_id))
        
        setValue("video", ofProperty: "type")
        self.created_at = NSDate()
        self.title = title
        self.video_id = video_id
    }
    
    override init!(document: CBLDoc) {
        super.init(document: document)
    }
    
    class func queryVideos() -> CBLView {
        let view = CouchbaseManager.shared.currentDatabase.viewNamed("videos")
        if view.mapBlock == nil {
            view.setMapBlock({ (doc, emit) -> Void in
                if let type = doc["type"] as? String {
                    if type == "video" {
                        emit(doc["_id"], doc)
                    }
                }
            }, version: "1")
        }
        return view
    }
    
}
