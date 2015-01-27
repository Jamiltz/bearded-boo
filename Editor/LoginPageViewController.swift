//
//  LoginPageViewController.swift
//  Editor
//
//  Created by James Nocentini on 21/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class LoginPageViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet var loginView: FBLoginView!
    @IBOutlet var backgroundMaskView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let shouldSkipLogin = CouchbaseManager.shared.currentUserId

        if (shouldSkipLogin != nil) {
            CouchbaseManager.shared.currentDatabase = CouchbaseManager.shared.databaseForUser(shouldSkipLogin!)
            
            let token = FBSession.activeSession().accessTokenData
            CouchbaseManager.shared.startReplicationWithFacebookAccessToken(token.accessToken)
            
            performSegueWithIdentifier("LoginSegue", sender: self)
        } else {
            loginView.readPermissions = ["public_profile", "email"]
            loginView.delegate = self
        }
    
        
        
        insertBlurView(backgroundMaskView, UIBlurEffectStyle.Dark)
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
        let token = FBSession.activeSession().accessTokenData
        
        // FATAL :: http call crashing the app when offline
        FBRequestConnection.startForMeWithCompletionHandler { (connection, result, error) -> Void in
            let shouldSkipLogin = CouchbaseManager.shared.currentUserId
            if shouldSkipLogin == nil {
                CouchbaseManager.shared.loginWithFacebookUserInfo(result, token: token)
                self.performSegueWithIdentifier("LoginSegue", sender: self)
            } else {
                CouchbaseManager.shared.loginWithFacebookUserInfo(result, token: token)
            }
        }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
