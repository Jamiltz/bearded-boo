import UIKit

class Pick: CBLModel {
    
    @NSManaged var video_id: String
    @NSManaged var start_at: Double
    @NSManaged var end_at: Double
    
    
    init(video_id: String, start_at: Double?, end_at: Double) {
        super.init(document: kDatabase.createDocument())
        
        setValue("pick", ofProperty: "type")
        self.video_id = video_id

        if let start = start_at {
            self.start_at = start
        }

        self.end_at = end_at
    }
    
    override init!(document: CBLDoc) {
        super.init(document: document)
    }
    
    class func queryUserPicks() -> CBLQuery {
        let view = kDatabase.viewNamed("user_picks")
        if view.mapBlock == nil {
            view
                .setMapBlock({ (doc, emit) -> Void in
                    if let type = doc["type"] as? String {
                        if type == "pick" {
                            emit(doc["video_id"], nil)
                        }
                    }
                }, reduceBlock: {(keys, values, rereduce) -> AnyObject! in
                    var unique_keys: [String : Int] = [:]
                    
                    for key in keys as [String] {
                        if let _ = unique_keys[key] {
                            unique_keys[key]!++
                        } else {
                            unique_keys[key] = 1
                        }
                    }
                    
                    return unique_keys
                }, version: "0")
        }
        let query = view.createQuery()
        
        return query
    }
    
    class func queryVideoPicks(video_id: String) -> CBLQuery {
        let view = kDatabase.viewNamed("video_picks")
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
        let view = kDatabase.viewNamed("snippets")
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
        let view = kDatabase.viewNamed("all_snippets")
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