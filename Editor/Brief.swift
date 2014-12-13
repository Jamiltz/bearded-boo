//
//  Recap.swift
//  Editor
//
//  Created by James Nocentini on 25/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class Brief: CBLModel {
   
    @NSManaged var video_id: String
    @NSManaged var updated_at: NSDate
    @NSManaged var picks: [Pick]
    @NSManaged var fb_id: String
    @NSManaged var name: String
    @NSManaged var caption: String
    
    init(video_id: String, updated_at: NSDate, picks: [Pick], fb_id: String, name: String, caption: String) {
        
        super.init(document: CouchbaseManager.shared.currentDatabase.documentWithID("b:\(video_id)"))
        
        setValue("brief", ofProperty: "type")
        self.video_id = video_id
        self.updated_at = updated_at
        self.picks = picks
        self.fb_id = fb_id
        self.name = name
        self.caption = caption
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
