import UIKit

class EditPicksCell: UICollectionViewCell {
    
    @IBOutlet var highlightView: UIView!
    @IBOutlet var indexLabel: UILabel!
    
    override var selected: Bool {
        didSet {
            backgroundColor = selected ? UIColor.whiteColor() : UIColor.clearColor()
        }
    }
    
    var highlight: Bool? {
        didSet {
            if highlight! {
                highlightView.backgroundColor = kGreenColor
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        highlight = false
        highlightView.backgroundColor = UIColor.clearColor()
    }
    
}
