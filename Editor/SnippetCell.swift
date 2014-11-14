import UIKit

class SnippetCell: UICollectionViewCell {
    
    @IBOutlet var image: UIImageView!
    
    var user_id_for_thumbnail: String? {
        didSet {
            if let id = user_id_for_thumbnail {
                let stringUrl = "https://graph.facebook.com/\(id)/picture?type=square"
                let url = NSURL(string: stringUrl)!
            }
        }
    }
    
    override func prepareForReuse() {
        image.image = UIImage()
    }
    
}
