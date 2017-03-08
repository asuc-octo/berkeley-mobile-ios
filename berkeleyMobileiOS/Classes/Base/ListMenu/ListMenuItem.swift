
import UIKit
import Material

/**
 * `ListMenuItem` is a data wrapper designed to be used with `ListMenuController`.
 * It behaves similarly to `UIAlertAction` with extra properties for configuring icons on `ListMenuCell`. 
 */
class ListMenuItem
{
    var text: String
    var icon: UIImage?
    var tint: UIColor
    var isSelected: Bool
    
    var handler: ((ListMenuItem) -> Void)?
    
    init(text: String, icon: UIImage?, tint: UIColor = Color.grey.base, selected: Bool = false, handler: ((ListMenuItem) -> Void)? = nil)
    {
        self.text = text
        self.icon = icon
        self.tint = tint
        self.isSelected = selected
        
        self.handler = handler
    }
}
