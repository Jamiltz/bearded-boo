//
//  StepsViewController.swift
//  Editor
//
//  Created by James Nocentini on 16/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class StepsViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var liveQuery: CBLLiveQuery!
    var picks: [Pick] = []

    deinit {
        liveQuery.removeObserver(self, forKeyPath: "rows")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        liveQuery = Pick.queryAllSnippets().asLiveQuery()
        liveQuery.addObserver(self, forKeyPath: "rows", options: .allZeros, context: nil)
        liveQuery.run(nil)
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if (object as! CBLLiveQuery) == liveQuery {
            picks = liveQuery.rows.allObjects
                .map({(row) -> Pick in
                    let doc = (row as! CBLQueryRow).document
                    return Pick(document: doc)
                })
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return picks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("StepCell") as! UITableViewCell
        
        let attachment: CBLAttachment? = picks[indexPath.item].attachmentNamed("image")
        if let unwrapped = attachment {
            cell.imageView!.image = UIImage(data: unwrapped.content)
            cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFill
        }
        
        return cell
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
