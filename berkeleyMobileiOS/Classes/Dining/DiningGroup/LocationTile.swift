
import UIKit

fileprivate let kColorRed = UIColor.red
fileprivate let kColorGray = UIColor(white: 189/255.0, alpha: 1)
fileprivate let kColorNavy = UIColor(red: 0, green: 51/255.0, blue: 102/255.0, alpha: 1)
fileprivate let kColorGreen = UIColor(red: 16/255.0, green: 161/255.0, blue: 0, alpha:1)


/**
 * LocationTile represents a single DiningHall.
 * It shows a thumbnail image, name, open status, and a save/favorite button.
 */
class LocationTile: UICollectionViewCell, RequiresData
{
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var favoriteButton: ToggleButton! 
    
    /// Configure the border and shadow, which can't be set in the interface builder.
    override func awakeFromNib()
    {
        let layer = self.layer
        layer.borderWidth = 1
        layer.borderColor = kColorGray.cgColor
        
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
    }
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = DiningHall
    
    /// Receive DiningHall to represent, and connect all data.
    public func setData(_ data: DataType)
    {
        let hall = data
        self.nameLabel.text = hall.name
        
        let status = hall.isOpen ? ("OPEN", kColorGreen) : ("CLOSED", kColorRed)
        self.statusLabel.text = status.0
        self.statusLabel.textColor = status.1
        
        imageView.contentMode = .scaleAspectFill
        imageView.load(url: hall.imageURL)
    }
}
