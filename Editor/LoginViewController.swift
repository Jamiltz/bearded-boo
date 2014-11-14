//
//  LoginViewController.swift
//  Story1
//
//  Created by James Nocentini on 03/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate {
    
    @IBOutlet var loginView: FBLoginView!
    
    @IBOutlet var profilePictureView: FBProfilePictureView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var homeButton: UIButton!
    
    
    var shouldSkipLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        loginView.readPermissions = ["public_profile", "email"]
        loginView.delegate = self

        if shouldSkipLogin {
            start()
        }
    }
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        profilePictureView.hidden = false
        profilePictureView.profileID = user.objectID
        nameLabel.hidden = false
        nameLabel.text = user.name
        homeButton.hidden = false
        
        let token = FBSession.activeSession().accessTokenData
        
        FBRequestConnection.startForMeWithCompletionHandler { (connection, result, error) -> Void in
           CouchbaseManager.shared.loginWithFacebookUserInfo(result, token: token)
        }
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        profilePictureView.hidden = true
        nameLabel.text = ""
        homeButton.hidden = true
    }
    
    func start() {
        performSegueWithIdentifier("LoginSegue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
//        FacebookManager.shared.loginWithFacebook { (success, error) -> () in
//            if success {
//                self.performSegueWithIdentifier("LoginSegue", sender: self)
//            }
//        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
