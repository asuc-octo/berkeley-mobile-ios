
import UIKit

fileprivate let kColorRed = UIColor.red
fileprivate let kColorNavy = UIColor(red: 0, green: 51/255.0, blue: 102/255.0, alpha: 1)
fileprivate let kColorGreen = UIColor(red: 16/255.0, green: 161/255.0, blue: 0, alpha:1)

fileprivate let kImageSize: CGFloat = 28.0
fileprivate let kHeartEmpty = "heart_emtpy"
fileprivate let kHeartFilled = "heart_filled"


/**
 *
 */
class LocationTile: UICollectionViewCell, RequiresData
{
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton! 
    
    
    override func awakeFromNib()
    {
        self.clipsToBounds = true
        self.imageView.clipsToBounds = true
        
        self.favoriteButton.setImage(UIImage(named: "heart_empty"), for: .normal)
        self.favoriteButton.setImage(UIImage(named: "heart_filled"), for: .selected)
    }
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = DiningHall
    
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
    
    
    // ========================================
    // MARK: - Layout
    // ========================================    
    /**
     *
     */
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let imageInset = round((self.favoriteButton.frame.height - kImageSize) / 2)
        self.favoriteButton.imageEdgeInsets = UIEdgeInsetsMake(imageInset, imageInset, imageInset, imageInset)
    }
    
    
    @IBAction func favoritePressed()
    {
        self.favoriteButton.isSelected = !self.favoriteButton.isSelected
    }
}
