import UIKit

class EditPicksCell: UITableViewCell {
    
    @IBOutlet var highlightView: UIView!
    @IBOutlet var indexLabel: UILabel!
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var captionLabel: UILabel!
    
//    override var selected: Bool {
//        didSet {
//            backgroundColor = selected ? kGrayColor : UIColor.clearColor()
//        }
//    }
    
    var highlight: Bool? {
        didSet {
            if highlight! {
                highlightView.backgroundColor = kBlueIconColor
            }
        }
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        highlight = false
        captionLabel.text = ""
//        highlightView.backgroundColor = UIColor.clearColor()
    }
    
}
