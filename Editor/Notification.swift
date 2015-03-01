//
//  Notification.swift
//  Editor
//
//  Created by James Nocentini on 13/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class Notification: CBLModel {
    
    @NSManaged var device_token: String
    @NSManaged var user_name: String
    
    init(device_token: String, user_name: String) {
        
        super.init(document: CouchbaseManager.shared.currentDatabase.createDocument(), orDatabase: nil)
        
        setValue("notification", ofProperty: "type")
        self.device_token = device_token
        self.user_name = user_name
    }
    
    init(document: CBLDocument) {
        super.init(document: document, orDatabase: nil)
    }
   
}
