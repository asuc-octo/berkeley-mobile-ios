
import UIKit

fileprivate let kColorRed = UIColor.red
fileprivate let kColorGray = UIColor(white: 189/255.0, alpha: 1)
fileprivate let kColorNavy = UIColor(red: 0, green: 51/255.0, blue: 102/255.0, alpha: 1)
fileprivate let kColorGreen = UIColor(red: 16/255.0, green: 161/255.0, blue: 0, alpha:1)


/**
 * LocationTile represents a single DiningHall.
 * It shows a thumbnail image, name, open status, and a save/favorite button.
 */
class LocationTile: UICollectionViewCell, RequiresData, ToggleButtonDelegate
{
    // Data
    private var hall: DiningHall! // TODO: Update to handle any Location.

    // UI
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var favoriteButton: ToggleButton! 
    
    
    /// Configure any visual elements that does not require data.
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
    typealias DataType = (hall: DiningHall, favorited: Bool)
    
    /// Receive DiningHall to represent, and connect all data.
    public func setData(_ data: DataType)
    {
        self.hall = data.hall
        self.nameLabel.text = self.hall.name
        
        let status = self.hall.isOpen ? ("OPEN", kColorGreen) : ("CLOSED", kColorRed)
        self.statusLabel.text = status.0
        self.statusLabel.textColor = status.1
        
        self.imageView.load(url: hall.imageURL)
        self.favoriteButton.isSelected = data.favorited
    }
    
    
    // ========================================
    // MARK: - ToggleButtonDelegate
    // ========================================
    /**
     * Called when the favoriteButton on the tile is toggled.
     * Pass the event through the FavoriteCallback. 
     */
    func buttonDidToggle(_ button: ToggleButton)
    {
        let store = FavoriteStore.sharedInstance
        let action = (button.isSelected ? store.add : store.remove)
        action(DiningHall.self, hall.name)
    }
}
