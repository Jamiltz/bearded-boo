import UIKit

class Profile: CBLModel {
   
    @NSManaged var name: String
    @NSManaged var user_id: String
    @NSManaged var fb_id: String
    @NSManaged var device_token: String?
    
    init(name: String, user_id: String, fb_id: String) {
        
        super.init(document: kDatabase.documentWithID("p:\(user_id)"))
        
        setValue("profile", forKey: "type")
        self.name = name
        self.user_id = user_id
        self.fb_id = fb_id
        
    }
    
    override init!(document: CBLDoc) {
        super.init(document: document)
    }
    
    class func profileInDatabase(userId: String) -> Profile? {
        let profileDocId = "p:\(userId)"
        let doc = kDatabase.existingDocumentWithID(profileDocId)
        if doc != nil {
            return Profile(forDocument: doc)
        } else {
            return nil
        }
    }
    
}
