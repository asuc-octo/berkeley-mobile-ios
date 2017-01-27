
import UIKit


protocol ToggleButtonDelegate
{
    func buttonDidToggle(_ button: ToggleButton)
}

/**
 * Button that toggles between normal and selected states when tapped.  
 *
 * When a `UIControlEvent.touchUpInside` is triggered, button will flip the `isSelected` state,
 * then traverse up the responder chain until it finds one that implements `ToggleButtonDelegate`
 * and fire the `buttonDidToggle(_:)` function.
 *
 * This allows for any `UIResponder` up the chain to implment `ToggleButtonDelegate` and handle the event,
 * not just the direct parent of the button.
 *
 * - Note: 
 *  When `addTarget(_:action:for:)` directly on ToggleButton for a `.touchUpInside` event,
 *  the `isSelected` state is not guaranteed to be flipped before the the action is called.
 *  Any action that requires the updated the state should implment 
 */
class ToggleButton: UIButton
{    
    override func awakeFromNib()
    {
        self.addTarget(self, action: #selector(toggled), for: .touchUpInside)
    }
    
    func toggled()
    {
        self.isSelected = !self.isSelected
        
        var next = self.next
        while next.notNil && (next as? ToggleButtonDelegate).isNil  
        {
            next = next?.next
        }
        
        if let delegate = next as? ToggleButtonDelegate
        {
            delegate.buttonDidToggle(self)
        }
    }
}
