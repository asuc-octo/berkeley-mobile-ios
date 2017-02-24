
import UIKit


fileprivate let kCellPadding: CGFloat = 12.0
fileprivate let kContentHeight: CGFloat = 44.0


/**
 * TableViewCell to represent a single DiningMenu item. 
 */
class DiningItemCell: UITableViewCell, RequiresData, ToggleButtonDelegate
{
    // Data
    private var item: DiningItem!

    // UI
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = (item: DiningItem, favorited: Bool)
    
    /// Receive the DiningItem to represent, whehter it's already favorited, and an optional callback. 
    func setData(_ data: DataType)
    {
        self.item = data.item
        self.nameLabel.text = data.item.name
        
        self.favoriteButton.isSelected = data.favorited
    }
    
    
    // ========================================
    // MARK: - ToggleButtonDelegate
    // ========================================
    /**
     * When the favoriteButton is toggled, update the FavoriteStore.
     * 
     * - Note:
     *  Ideally updating the Store should be done in a controller, 
     *  but because that requires an extra layer of delegation/callback,
     *  opted to include the Store write action here.
     */
    func buttonDidToggle(_ button: ToggleButton)
    {
        let store = FavoriteStore.shared
        let action = (button.isSelected ? store.add : store.remove)
        action(item)
    }
}
