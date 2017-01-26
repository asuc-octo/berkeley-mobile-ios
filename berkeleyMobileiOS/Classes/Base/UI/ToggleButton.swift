
import UIKit

/**
 * Button that toggles between normal and selected states when tapped.
 * Otherwise it acts the same as a regular UIButton,
 * so all other aspects need to be configured through the interface builder. 
 */
class ToggleButton: UIButton
{
    var callback: ((Bool) -> Void)? = nil

    /// Call toggle() when a touchUpInside event occurs.
    override func awakeFromNib()
    {
        self.addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }
    
    
    /// Toggle the selected state and call the handler if there is one.
    func toggle()
    {
        self.isSelected = !self.isSelected
        callback?(self.isSelected)
    }
}
