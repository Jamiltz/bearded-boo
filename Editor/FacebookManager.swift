import Foundation

class FacebookManager {
    class var shared: FacebookManager {
        struct Static {
            static let instance: FacebookManager = FacebookManager()
        }
        return Static.instance
    }
    
    var facebookLoginCallback: ((success: Bool, error: NSError) -> ())!
    
    // can go in singleton
//    func notifyFacebookLoginResult(result: Bool, error: NSError) {
//        if facebookLoginCallback != nil {
//            self.facebookLoginCallback(success: result, error: error)
//        }
//    }
//    
//    // can go in singleton
//    func loginWithFacebook(result: (success: Bool, error: NSError) -> ()) {
//        self.facebookLoginCallback = result
//        openFacebookSession()
//    }
//    
//    // can go in singleton
    func openFacebookSession() {
        FBSession.openActiveSessionWithReadPermissions(["public_profile", "email"], allowLoginUI: false) { (session, state, error) -> Void in
            self.facebookSessionStateChanged(session, state: state, error: error)
        }
    }
//
//    // can go in singleton
    func facebookSessionStateChanged(session: FBSession, state: FBSessionState, error: NSError!) {
        if (state == FBSessionState.Open) {
            FBRequestConnection.startForMeWithCompletionHandler({ (connection, result, error) -> Void in
                CouchbaseManager.shared.loginWithFacebookUserInfo(result, token: session.accessTokenData)
                if error != nil {
                    
                } else {
                    
                }
//                self.notifyFacebookLoginResult(true, error: NSError())
            })
            return
        }
    }
//
//    // can go in singleton
//    func loginWithFacebookUserInfo(result: AnyObject, token: FBAccessTokenData) {
//        
//    }
}