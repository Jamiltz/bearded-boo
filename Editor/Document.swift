import UIKit

class Player: CBLModel {
    
    @NSManaged var firstname: String
    
    init(firstname: String) {
        super.init(document: CouchbaseManager.shared.currentDatabase.createDocument(), orDatabase: nil)
        
        setValue("player", ofProperty: "type")
        self.firstname = firstname
    }
    
    init(document: CBLDocument) {
        super.init(document: document, orDatabase: nil)
    }
    
    class func queryPlayers() {
        // view code
    }
    
}
