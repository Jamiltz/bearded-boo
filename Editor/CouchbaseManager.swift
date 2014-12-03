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
    
    var currentDatabase: CBLDatabase!
    
    func loginWithFacebookUserInfo(result: AnyObject, token: FBAccessTokenData) {
        
        let userId = result["email"] as String
        let name = result["name"] as String
        
        let database = databaseForUser(userId)
        currentDatabase = database
        
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
            pull = CouchbaseManager.shared.currentDatabase.createPullReplication(syncURL)
            pull.continuous = true
            if (!kSyncGatewayWebSocketSupport) {
                pull.customProperties = ["websocket": false];
            }
            
            push = CouchbaseManager.shared.currentDatabase.createPushReplication(syncURL)
            push.continuous = true
            
//            let notificationCenter = NSNotificationCenter.defaultCenter()
//            notificationCenter.addObserver(self, selector: "replicationProgress:", name: kCBLReplicationChangeNotification, object: pull)
//            notificationCenter.addObserver(self, selector: "replicationProgress:", name: kCBLReplicationChangeNotification, object: push)
        }
        
        let auth = CBLAuthenticator.facebookAuthenticatorWithToken(token)
        pull.authenticator = auth
        push.authenticator = auth
        
        pull.start()
        push.start()
        
    }
    
    func replicationProgress(notification: NSNotification) {
        if pull.status == CBLReplicationStatus.Active || push.status == CBLReplicationStatus.Active {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        } else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
        println(pull.lastError)
        println(push.lastError)
    }
    
    func stopReplication() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        if pull != nil {
            pull.stop()
            notificationCenter.removeObserver(self, name: kCBLReplicationChangeNotification, object: pull)
            pull = nil
        }
        if push != nil {
            push.stop()
            notificationCenter.removeObserver(self, name: kCBLReplicationChangeNotification, object: push)
            push = nil
        }
        
    }
    
    func databaseForUser(user: String) -> CBLDatabase {
        let hash = String(format: "db%@", arguments: [user.md5.lowercaseString])
        println("hash name :: \(hash)")
        var error: NSError?
        let database = CBLManager.sharedInstance().databaseNamed(hash, error: &error)
        if (error != nil) {
            println("cannot create database because \(error)")
        }
        return database
    }
    
}