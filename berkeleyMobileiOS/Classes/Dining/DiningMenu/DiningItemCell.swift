
import UIKit


fileprivate let kCellPadding: CGFloat = 16.0

/**
 * TableViewCell to represent a single DiningMenu item. 
 */
class DiningItemCell: UITableViewCell, RequiresData
{
    // UI
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var button: UIButton!
    
    // Data
    var item: DiningItem?
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = DiningItem
    
    func setData(_ data: DiningItem)
    {
        self.item = data
        
        self.label.text = data.name
//        self.button.setTitle(data.name, for: .normal)
    }
}
