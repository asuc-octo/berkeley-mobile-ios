
import UIKit


fileprivate let kCellPadding: CGFloat = 12.0
fileprivate let kContentHeight: CGFloat = 44.0

fileprivate let kImageSize: CGFloat = 22.0


/**
 * TableViewCell to represent a single DiningMenu item. 
 */
class DiningItemCell: UITableViewCell, RequiresData
{
    // UI
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var saveButton: SaveButton!
    
    // Data
    var item: DiningItem?
    
    
    // ========================================
    // MARK: - Setup
    // ========================================
    override func awakeFromNib()
    {
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
}
