//
//  TabViewController.swift
//  Editor
//
//  Created by James Nocentini on 15/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        tabBarController?.tabBar.barStyle = UIBarStyle.BlackTranslucent
        // Do any additional setup after loading the view.
        
        if let shouldSkipLogin = CouchbaseManager.shared.currentUserId {
            
        } else {
            performSegueWithIdentifier("loginSegue", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
