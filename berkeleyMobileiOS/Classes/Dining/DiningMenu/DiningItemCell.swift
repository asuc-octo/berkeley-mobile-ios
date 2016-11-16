
import UIKit

/**
 * TableViewCell to represent a single DiningMenu item. 
 */
class DiningItemCell: UITableViewCell, RequiresData
{
    // UI
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var button: UIButton?
    
    // Data
    var item: DiningItem?
    
    
    // MARK: - RequiresData
    typealias DataType = DiningItem
    
    func setData(_ data: DiningItem)
    {
        self.item = data
    }
}
