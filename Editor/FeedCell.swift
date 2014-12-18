//
//  FeedCell.swift
//  Editor
//
//  Created by James Nocentini on 12/12/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class FeedCell: UICollectionViewCell {
    
    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var thumbnailUser: UIImageView!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var videoLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    var video_id: String = "" {
        didSet {
            let url = NSURL(string: "https://i.ytimg.com/vi/\(video_id)/0.jpg")!
            thumbnail.sd_setImageWithURL(url)
        }
    }
    
    var facebookUserId: String? {
        didSet {
            if let id = facebookUserId {
                let url = NSURL(string: "https://graph.facebook.com/\(id)/picture?type=large")
                thumbnailUser.sd_setImageWithURL(url)
            }
        }
    }
    
    override var selected: Bool {
        didSet {
            backgroundColor = selected ? kBlueIconColor : UIColor.whiteColor()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnail.image = nil
        thumbnailUser.image = nil
        nameLabel.text = ""
    }
    
}
