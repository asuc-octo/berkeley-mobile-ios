
import UIKit
import Firebase

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
//    @IBOutlet private weak var favoriteButton: UIButton!
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = DiningItem
    
    /// Receive the DiningItem to represent, whehter it's already favorited, and an optional callback. 
    func setData(_ item: DataType)
    {
        self.item = item
        nameLabel.text = item.name
//        favoriteButton.isSelected = item.isFavorited
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
//        item.isFavorited = button.isSelected
//        FavoriteStore.shared.update(item)
//        Analytics.logEvent("favorited_food_item", parameters: ["food_item" : item.name])

    }
}
