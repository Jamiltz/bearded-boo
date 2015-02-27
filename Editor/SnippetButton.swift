//
//  SnippetButton.swift
//  Story1
//
//  Created by James Nocentini on 08/11/2014.
//  Copyright (c) 2014 James Nocentini. All rights reserved.
//

import UIKit

@IBDesignable
class SnippetButton: UIButton {

//    @IBInspectable
    var isActive: Bool = false {
        didSet {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                if !self.isActive {
                    self.layer.backgroundColor = kGreenColor.CGColor
                } else {
                    self.layer.backgroundColor = kRedColor.CGColor
                }
            })
            
            let anim = CABasicAnimation(keyPath: "cornerRadius")
            
            if !isActive {
                anim.fromValue = 8
                anim.toValue = bounds.width / 2
            } else {
                anim.fromValue = bounds.width / 2
                anim.toValue = 8
            }
            
            anim.duration = 0.2
            layer.addAnimation(anim, forKey: "cornerRadius")
            layer.cornerRadius = anim.toValue as! CGFloat
        }
    }
    
    

}
