
import UIKit
import Material

fileprivate let kHeight: CGFloat = 48.0
fileprivate let kCellPadding: CGFloat = 16.0
fileprivate let kLabelMargin: CGFloat = 72.0

fileprivate let kImageSize: CGFloat = 20.0
fileprivate let kImageMargin: CGFloat = round((kHeight - kImageSize)/2) 

fileprivate let kFontSize: CGFloat = 15.0


/**
 * `ListMenuHeader` is a view designed to be used by `ListMenuController`
 */
class ListMenuHeader: UITableViewHeaderFooterView
{
    static let preferredHeight: CGFloat = 52.0
    
    
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("ListMenuHeader cannot be used in InterfaceBuilder")
    }
    
    override init(reuseIdentifier: String?)
    {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
    }
}


/**
 * `ListMenuCell` is a type of `UITableViewCell` designed to be used by `ListMenuController`.
 *
 * It includes:
 * - Primary icon to the left
 * - Text describing the menu
 * - Secondary icon to the right
 *
 */
class ListMenuCell: UITableViewCell
{
    static let desiredHeight: CGFloat = kHeight
    
    // Private
    private var item: ListMenuItem!
    
    private var touchInside: Bool = false
    {
        didSet { animateHighlight() }
    }
    
    
    // ========================================
    // MARK: - UITableViewCell
    // ========================================
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("ListMenuCell should not be used in InterfaceBuilder")
    }

    /// Configure constant settings for subviews.
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) 
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        imageView?.contentMode = .scaleAspectFit
        
        textLabel?.numberOfLines = 1
        textLabel?.textColor = .black
        textLabel?.lineBreakMode = .byTruncatingTail
        textLabel?.font = RobotoFont.regular(with: kFontSize)
        
        accessoryView = UIImageView(image: #imageLiteral(resourceName: "ic_check"))
        accessoryView?.tintColor = Color.green.base
    }
    
    /// Show or hide the check icon depending on selection state. 
    override var isSelected: Bool
    {
        didSet {
            accessoryView?.isHidden = !isSelected
            setNeedsLayout()
        }
    }
    
    
    /// Layout the icons and text.
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let size = self.bounds.size
        let iconSize = CGSize(width: kImageSize, height: kImageSize)
        
        let iconOrigin = CGPoint(x: kCellPadding, y: kImageMargin)
        imageView?.frame = CGRect(origin: iconOrigin, size: iconSize)
        
        let check = accessoryView
        let checkOrigin = CGPoint(x: size.width - iconSize.width - kCellPadding, y: kImageMargin)
        check?.frame = CGRect(origin: checkOrigin, size: iconSize)
        
        
        // If selected and check is shown, shrink the label's width appropriately.
        let labelWidth = (isSelected ? checkOrigin.x : size.width) - kLabelMargin
        textLabel?.frame = CGRect(x: kLabelMargin, y: 0, width: labelWidth, height: size.height)
    }
    
    /// Start tracking whether touch is inside.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesBegan(touches, with: event)
        touchInside = true
    }
    
    /// Whenever touch leaves or enters the cell, update flag.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesMoved(touches, with: event)
    
        if let point = touches.first?.location(in: self)
        {
            let newState = bounds.contains(point)
            if newState != touchInside {
                touchInside = newState
            }
        }
    }
    
    /// Call the handler only if touchUpInside.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        super.touchesEnded(touches, with: event)
        
        if touchInside
        {
            touchInside = false
            item?.handler?(item)
        }
    }
    
    /// Given a `ListMenuItem` to show, the cell will automatically update itself.
    func setItem(_ item: ListMenuItem)
    {
        imageView?.image = item.icon
        imageView?.tintColor = item.tint
        
        textLabel?.text = item.text
        isSelected = item.isSelected
        
        self.item = item
        setNeedsLayout()
    }
    
    /// Animate highlight of background color depending on the touchInside state.
    private func animateHighlight()
    {
        layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2)
        { 
            self.backgroundColor = UIColor(white: self.touchInside ? 0.96 : 1, alpha: 1)
        } 
    }
}
