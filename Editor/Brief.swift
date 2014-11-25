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
    @NSManaged var status: String
    @NSManaged var link: String
    
    init(video_id: String, updated_at: NSDate, status: String, link: String) {
        
        super.init(document: kDatabase.documentWithID("b:\(video_id)"))
        
        setValue("brief", ofProperty: "type")
        self.video_id = video_id
        self.updated_at = updated_at
        self.status = status
        self.link = link
    }
    
    override init!(document: CBLDoc) {
        super.init(document: document)
    }
    
    class func briefForVideoInDatabase(video_id: String) -> Brief? {
        let briefDocId = "b:\(video_id)"
        let doc = kDatabase.existingDocumentWithID(briefDocId)
        if doc != nil {
            return Brief(forDocument: doc)
        } else {
            return nil
        }
    }
    
}
