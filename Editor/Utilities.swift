import Foundation

func insertBlurView (view: UIView, style: UIBlurEffectStyle) {
    view.backgroundColor = UIColor.clearColor()
    
    var blurEffect = UIBlurEffect(style: style)
    var blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.frame = view.bounds
    blurEffectView.layer.opacity = 0.5
    view.insertSubview(blurEffectView, atIndex: 0)
}

func spring(duration: NSTimeInterval, animations: (() -> Void)) {
    UIView.animateWithDuration(duration, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: nil, animations: {
        animations()
    }, completion: nil)
}