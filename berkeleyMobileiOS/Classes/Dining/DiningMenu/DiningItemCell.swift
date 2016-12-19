
import UIKit


fileprivate let kCellPadding: CGFloat = 12.0
fileprivate let kContentHeight: CGFloat = 44.0

fileprivate let kImageSize: CGFloat = 22.0
fileprivate let kHeartEmpty = "heart_emtpy"
fileprivate let kHeartFilled = "heart_filled"


/**
 * TableViewCell to represent a single DiningMenu item. 
 */
class DiningItemCell: UITableViewCell, RequiresData
{
    // UI
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    // Data
    var item: DiningItem?
    
    
    // ========================================
    // MARK: - Setup
    // ========================================
    /**
     *
     */
    override func awakeFromNib()
    {
        self.favoriteButton.setImage(UIImage(named: "heart_empty"), for: .normal)
        self.favoriteButton.setImage(UIImage(named: "heart_filled"), for: .selected)
        
        // TODO: ask DiningDataStore if item is already favorited. 
    }
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = DiningItem
    
    func setData(_ data: DiningItem)
    {
        self.item = data
        
        self.nameLabel.text = data.name
    }
    
    
    // ========================================
    // MARK: - Layout
    // ========================================
    /**
     * 
     */
    static func sizeForData(_ data: DiningItem) -> CGSize
    {
        return CGSize(width: 0, height: kImageSize + (2 * kCellPadding))
    }
    
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
