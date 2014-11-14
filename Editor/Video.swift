import UIKit

class Video: CBLModel {
   
    @NSManaged var url: NSURL
    @NSManaged var created_at: NSDate
    @NSManaged var title: String
    @NSManaged var identifier: String
    @NSManaged var image_url: NSURL
    
    init(url: NSURL, title: String, identifier: String, image_url: NSURL) {
        
        super.init(document: kDatabase.createDocument())
        
        setValue("video", ofProperty: "type")
        self.url = url
        self.created_at = NSDate()
        self.title = title
        self.identifier = identifier
        self.image_url = image_url
    }
    
    override init!(document: CBLDoc) {
        super.init(document: document)
    }
    
    class func queryVideos() -> CBLView {
        let view = kDatabase.viewNamed("videos")
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
