import UIKit

class Pick: CBLModel {
    
    @NSManaged var video_id: String
    @NSManaged var start_at: Double
    @NSManaged var end_at: Double
    @NSManaged var caption: String?
    @NSManaged var highlight: Bool
    @NSManaged var video_title: String
    @NSManaged var user_id: String
    
    init(video_id: String, start_at: Double?, end_at: Double, caption: String, video_title: String, user_id: String) {
        super.init(document: CouchbaseManager.shared.currentDatabase.createDocument())
        
        setValue("pick", ofProperty: "type")
        self.video_id = video_id

        if let start = start_at {
            self.start_at = start
        }

        self.end_at = end_at
        self.caption = caption
        self.video_title = video_title
        self.user_id = user_id
    }
    
    override init!(document: CBLDoc) {
        super.init(document: document)
    }
    
    class func queryVideoPicks(video_id: String) -> CBLQuery {
        let view = CouchbaseManager.shared.currentDatabase.viewNamed("video_picks")
        if view.mapBlock == nil {
            view
                .setMapBlock({ (doc, emit) -> Void in
                    if let type = doc["type"] as? String {
                        if type == "pick" {
                            emit(doc["video_id"], doc)
                        }
                    }
                }, version: "1")
        }
        
        let query = view.createQuery()
        query.keys = [video_id]
        
        return query
    }
    
    class func querySnippetsForVideo(id: String) -> CBLQuery {
        let view = CouchbaseManager.shared.currentDatabase.viewNamed("snippets")
        if view.mapBlock == nil {
            view
                .setMapBlock({ (doc, emit) -> Void in
                    if let type = doc["type"] as? String {
                        if type == "pick" {
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
        let view = CouchbaseManager.shared.currentDatabase.viewNamed("all_snippets")
        if view.mapBlock == nil {
            view
                .setMapBlock({ (doc, emit) -> Void in
                    if let type = doc["type"] as? String {
                        if type == "pick" {
                            emit(doc["video_id"], doc)
                        }
                    }
                }, version: "1")
        }
        
        return view.createQuery()
    }
    
}