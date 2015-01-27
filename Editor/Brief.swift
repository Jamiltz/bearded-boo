//
//  Recap.swift
//  Editor
//
//  Created by James Nocentini on 25/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class Brief: CBLModel {
    
    @NSManaged var pick_id: String
    @NSManaged var profile_id: String
    @NSManaged var updated_at: NSDate
    
    init(pick_id: String, profile_id: String, updated_at: NSDate) {
        
        super.init(document: CouchbaseManager.shared.currentDatabase.createDocument())
        
        setValue("brief", ofProperty: "type")
        self.pick_id = pick_id
        self.profile_id = profile_id
        self.updated_at = updated_at
    }
    
    override init!(document: CBLDoc) {
        super.init(document: document)
    }
    
    class func briefForVideoInDatabase(video_id: String) -> Brief? {
        let briefDocId = "b:\(video_id)"
        let doc = CouchbaseManager.shared.currentDatabase.existingDocumentWithID(briefDocId)
        if doc != nil {
            return Brief(forDocument: doc)
        } else {
            return nil
        }
    }
    
    class func queryBriefs() -> CBLView {
        let view = CouchbaseManager.shared.currentDatabase.viewNamed("briefs")
        if view.mapBlock == nil {
            view.setMapBlock({ (doc, emit) -> Void in
                if let type = doc["type"] as? String {
                    if type == "brief" {
                        emit(doc["_id"], doc)
                    }
                }
            }, version: "1")
        }
        return view
    }
    
}
