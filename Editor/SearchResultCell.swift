//
//  SearchResultCell.swift
//  Editor
//
//  Created by James Nocentini on 30/12/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
    
    @IBOutlet var thumbnailImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    var video_id: String = "" {
        didSet {
            let url = NSURL(string: "https://i.ytimg.com/vi/\(video_id)/0.jpg")!
            thumbnailImageView.sd_setImageWithURL(url)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = ""
        video_id = ""
    }

}
