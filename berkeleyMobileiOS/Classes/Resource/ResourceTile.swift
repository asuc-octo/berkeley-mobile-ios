
import UIKit

fileprivate let kColorRed = UIColor.red
fileprivate let kColorGray = UIColor(white: 189/255.0, alpha: 1)
fileprivate let kColorNavy = UIColor(red: 0, green: 51/255.0, blue: 102/255.0, alpha: 1)
fileprivate let kColorGreen = UIColor(red: 16/255.0, green: 161/255.0, blue: 0, alpha:1)


/**
 * LocationTile represents a single DiningHall.
 * It shows a thumbnail image, name, open status, and a save/favorite button.
 */
class ResourceTile: UICollectionViewCell, RequiresData, ToggleButtonDelegate
{
    // Data
    private var resource: Resource!
    
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
    typealias DataType = Resource
    
    /// Receive DiningHall to represent, and connect all data.
    public func setData(_ resource: DataType)
    {
        self.resource = resource
        self.nameLabel.text = resource.name
        if (type(of: resource) == CampusResource.self || type(of: resource) == GymClass.self) {
            self.statusLabel.text = ""
        } else {
            let status = self.resource.isOpen ? ("OPEN", kColorGreen) : ("CLOSED", kColorRed)
            self.statusLabel.text = status.0
            self.statusLabel.textColor = status.1
        }

//        if (type(of: resource) == GymClass.self) {
        if let im = resource.image {
            self.imageView.image = im
        } else {
            switch resource.name {
            case "ALL-AROUND WORKOUT": do {
                self.imageView.image = #imageLiteral(resourceName: "ALL-AROUND WORKOUT")
                resource.image = #imageLiteral(resourceName: "ALL-AROUND WORKOUT")
            }
            case "CARDIO": do {
                self.imageView.image = #imageLiteral(resourceName: "CARDIO")
                resource.image = #imageLiteral(resourceName: "CARDIO")
            }
            case "MIND/BODY": do {
                self.imageView.image = #imageLiteral(resourceName: "MIND:BODY")
                resource.image = #imageLiteral(resourceName: "MIND:BODY")
            }
            case "DANCE": do {
                self.imageView.image = #imageLiteral(resourceName: "DANCE")
                resource.image = #imageLiteral(resourceName: "DANCE")
            }
            case "STRENGTH": do {
                self.imageView.image = #imageLiteral(resourceName: "STRENGTH")
                resource.image = #imageLiteral(resourceName: "STRENGTH")
            }
            case "AQUA": do {
                self.imageView.image = #imageLiteral(resourceName: "AQUA")
                resource.image = #imageLiteral(resourceName: "AQUA")
            }
            case "CORE": do {
                self.imageView.image = #imageLiteral(resourceName: "CORE")
                resource.image = #imageLiteral(resourceName: "CORE")
            }
            case "Recreational Sports Facility (RSF)": do {
                self.imageView.image = #imageLiteral(resourceName: "rsf")
                resource.image = #imageLiteral(resourceName: "rsf")
            }
            case "Stadium Fitness Center": do {
                self.imageView.image = #imageLiteral(resourceName: "stadium")
                resource.image = #imageLiteral(resourceName: "stadium")
                }
            case "Browns Cafe" : do {
                self.imageView.image = #imageLiteral(resourceName: "browns_cafe")
                resource.image = #imageLiteral(resourceName: "browns_cafe")
            }
            case "Golden Bear Cafe" : do {
                self.imageView.image = #imageLiteral(resourceName: "golden_bear_cafe")
                resource.image = #imageLiteral(resourceName: "golden_bear_cafe")
            }
            case "The Den" : do {
                self.imageView.image = #imageLiteral(resourceName: "the_den")
                resource.image = #imageLiteral(resourceName: "the_den")
            }
            case "Clark Kerr": do {
                self.imageView.image = #imageLiteral(resourceName: "ckc")
                resource.image = #imageLiteral(resourceName: "ckc")
                }
            default: do {
                self.imageView.load(resource: resource)
            }
            }
        }
        
//        } else {
//            self.imageView.load(url: resource.imageURL)
//        }
//        self.favoriteButton.isSelected = resource.isFavorited
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
        resource.isFavorited = button.isSelected
        FavoriteStore.shared.update(resource)
    }
}
