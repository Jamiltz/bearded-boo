import UIKit

class Snippet: CBLModel {
    
    @NSManaged var annotation: String
    @NSManaged var video_id: String
    @NSManaged var start_at: Double
    @NSManaged var end_at: Double
    
    init(annotation: String, video_id: String, start_at: Double, end_at: Double, image: NSData) {
        super.init(document: kDatabase.createDocument())
        
        setValue("snippet", ofProperty: "type")
        self.annotation = annotation
        self.video_id = video_id
        self.start_at = start_at
        self.end_at = end_at
        self.setAttachmentNamed("image", withContentType: "image/jpg", content: image)
    }
    
    override init!(document: CBLDoc) {
        super.init(document: document)
    }
    
    class func querySnippetsForVideo(id: String) -> CBLQuery {
        let view = kDatabase.viewNamed("snippets")
        if view.mapBlock == nil {
            view
                .setMapBlock({ (doc, emit) -> Void in
                    if let type = doc["type"] as? String {
                        if type == "snippet" {
                            emit(doc["video_id"], doc)
                        }
                    }
                }, version: "5")
        }
        
        let query = view.createQuery()
        query.keys = [id]
        
        return query
    }
    
    class func queryAllSnippets() -> CBLQuery {
        let view = kDatabase.viewNamed("all_snippets")
        if view.mapBlock == nil {
            view
                .setMapBlock({ (doc, emit) -> Void in
                    if let type = doc["type"] as? String {
                        if type == "snippet" {
                            emit(doc["video_id"], doc)
                        }
                    }
                }, version: "1")
        }
        
        return view.createQuery()
    }
    
}