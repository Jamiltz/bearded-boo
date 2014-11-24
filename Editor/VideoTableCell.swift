//
//  VideoTableCell.swift
//  Story1
//
//  Created by James Nocentini on 06/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

class VideoTableCell: UITableViewCell {
    

    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var title: UILabel!
    @IBOutlet var downloadButton: UIButton!
    
    var video_id: String = "" {
        didSet {
            let url = NSURL(string: "https://i.ytimg.com/vi/\(video_id)/0.jpg")!
            thumbnail.sd_setImageWithURL(url)
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
        title.text = ""
        thumbnail.image = nil
    }
    
}
