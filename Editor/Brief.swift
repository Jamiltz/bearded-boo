//
//  Recap.swift
//  Editor
//
//  Created by James Nocentini on 25/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class Brief: CBLModel {
    
    @NSManaged var pick_id: Pick
    @NSManaged var user_id: Profile
    var pick: Pick {
        return Pick(document: CouchbaseManager.shared.currentDatabase.existingDocumentWithID(document.propertyForKey("pick_id") as! String))
    }
    var user: Profile {
        return Profile(document: CouchbaseManager.shared.currentDatabase.existingDocumentWithID("p:" + (document.propertyForKey("user_id") as! String)))
    }
    
    init(pick: Pick, user: Profile) {
        super.init(document: CouchbaseManager.shared.currentDatabase.createDocument())
        
        setValue("brief", ofProperty: "type")
        self.pick_id = pick
        self.user_id = user
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
