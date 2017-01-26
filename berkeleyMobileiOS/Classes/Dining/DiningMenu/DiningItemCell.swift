
import UIKit


fileprivate let kCellPadding: CGFloat = 12.0
fileprivate let kContentHeight: CGFloat = 44.0


/**
 * TableViewCell to represent a single DiningMenu item. 
 */
class DiningItemCell: UITableViewCell, RequiresData
{
    // UI
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var favoriteButton: ToggleButton!
    
    // Data
    private var item: DiningItem!
    private var callback: ((String, Bool) -> Void)?
    
    
    // ========================================
    // MARK: - Setup
    // ========================================
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.favoriteButton.callback = self.toggled
    }
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = (item: DiningItem, favorited: Bool, toggled: ((String, Bool) -> Void)?)
    
    func setData(_ data: DataType)
    {
        self.item = data.item
        self.nameLabel.text = data.item.name
        
        self.callback = data.toggled
        self.favoriteButton.isSelected = data.favorited
    }
    
    
    func toggled(selected: Bool)
    {
        callback?(self.item.name, selected)
    }
}
