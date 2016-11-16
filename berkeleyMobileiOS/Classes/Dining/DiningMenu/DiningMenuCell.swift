
import UIKit

/**
 * TableViewCell to represent a single DiningMenu item. 
 */
class DiningMenuCell: UITableViewCell, RequiresData
{
    // UI
    @IBOutlet weak var label: UILabel?
    @IBOutlet weak var button: UIButton?
    
    // Data
    var menu: DiningMenu?
    
    
    // MARK: - RequiresData
    typealias DataType = DiningMenu
    
    func setData(_ data: DiningMenu)
    {
        self.menu = data
    }
}
