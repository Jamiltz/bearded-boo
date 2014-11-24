import UIKit

class EditPicksCell: UICollectionViewCell {
    
    @IBOutlet var indexLabel: UILabel!
    
    override var selected: Bool {
        didSet {
            backgroundColor = selected ? UIColor.whiteColor() : UIColor.clearColor()
        }
    }
    
}
