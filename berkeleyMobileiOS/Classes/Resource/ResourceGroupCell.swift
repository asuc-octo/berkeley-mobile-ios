
import UIKit
import Firebase

fileprivate let kResourceTileID = "ResourceTile"
fileprivate let kColorRed = UIColor.red
fileprivate let kColorGreen = UIColor(red: 16/255.0, green: 161/255.0, blue: 0, alpha:1)

/**
 * 
 */
class ResourceGroupCell: UITableViewCell, RequiresData
{
    // Data
    private var resource: Resource!

    // UI
    @IBOutlet weak var resourceImage: UIImageView!
    @IBOutlet weak var resourceTitleLabel: UILabel!
    @IBOutlet weak var openClosedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = Resource
    
    /**
     * Set the name, dining halls, and selection callback handler.
     * The carousel collectionView is reloaded.
     */
    public func setData(_ data: DataType)
    {
        self.resource = data
        self.resourceTitleLabel.text = resource.name
        self.resourceTitleLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
        
        if let image = resource.image {
            self.resourceImage.image = image
        } else {
            resourceImage.load(resource: resource)
        }
        
        let status = resource.isOpen ? ("OPEN", kColorGreen) : ("CLOSED", kColorRed)
        self.openClosedLabel.text = status.0
        self.openClosedLabel.textColor = status.1
    }
}
