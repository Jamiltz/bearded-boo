import Foundation

let kSyncGatewayUrl = "http://178.62.81.153:4984/editor"

class CouchbaseManager {
    class var shared: CouchbaseManager {
        struct Static {
            static let instance: CouchbaseManager = CouchbaseManager()
        }
        return Static.instance
    }
    
    var pull: CBLReplication!
    var push: CBLReplication!
    
    var currentUserId: String? {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            return defaults.objectForKey("user_id") as String?
        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(newValue, forKey: "user_id")
            defaults.synchronize()
        }
    }
    
    func logoutUser(sender: AnyObject) {
        println("log out user")
    }
    
    func loginWithFacebookUserInfo(result: AnyObject, token: FBAccessTokenData) {
        let userId = result["email"] as String
        let name = result["name"] as String
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(userId, forKey: "user_id")
        defaults.synchronize()
        
        
        var profile: Profile? = Profile.profileInDatabase(userId)
        
        if let _ = profile {
            println("profile")
        } else {
            println("no profile")
            profile = Profile(name: name, user_id: userId, fb_id: result["id"] as String)
            if profile!.save(nil) {
                println("profile saved")
            }
        }

        self.startReplicationWithFacebookAccessToken(token.accessToken)
        
    }
    
    func startReplicationWithFacebookAccessToken(token: String) {
        
        if pull == nil { // check its nil
            let syncURL = NSURL(string: kSyncGatewayUrl)
            pull = kDatabase.createPullReplication(syncURL)
            pull.continuous = true
            
            push = kDatabase.createPushReplication(syncURL)
            push.continuous = true
        }
        println(token)
        let auth = CBLAuthenticator.facebookAuthenticatorWithToken(token)
        pull.authenticator = auth
        push.authenticator = auth
        
        pull.start()
        push.start()
        
    }
    
    func stopReplication() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        if let _ = pull {
            pull.stop()
            notificationCenter.removeObserver(self, name: kCBLReplicationChangeNotification, object: pull)
            pull = nil
        }
        if let _ = push {
            push.stop()
            notificationCenter.removeObserver(self, name: kCBLReplicationChangeNotification, object: push)
            push = nil
        }
        
    }
    
}