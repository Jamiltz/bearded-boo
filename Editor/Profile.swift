import UIKit

class Profile: CBLModel {
   
    @NSManaged var name: String
    @NSManaged var user_id: String
    @NSManaged var fb_id: String
    @NSManaged var device_token: String?
    
    var moments: Int?
    
    init(name: String, user_id: String, fb_id: String) {
        
        super.init(document: CouchbaseManager.shared.currentDatabase.documentWithID("p:\(user_id)")!, orDatabase: nil)
        
        setValue("profile", forKey: "type")
        self.name = name
        self.user_id = user_id
        self.fb_id = fb_id
        
    }
    
    init(document: CBLDocument) {
        super.init(document: document, orDatabase: nil)
    }
    
    class func profileInDatabase(userId: String) -> Profile? {
        let profileDocId = "p:\(userId)"
        let doc = CouchbaseManager.shared.currentDatabase.existingDocumentWithID(profileDocId)
        if doc != nil {
            return Profile(document: doc!)
        } else {
            return nil
        }
    }
    
}
