
import UIKit
import Material

/**
 * Toolbar with a clear background and property for fade-in reveal title label. 
 */
class FadeTitleToolbar: Toolbar
{
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) 
    {
        super.init(frame: frame)
    }
    
    convenience init()
    {
        self.init(frame: CGRect.zero)
    }
    
    
    private let gradient = CAGradientLayer()
    
    /// Length of the fade gradient. Clamped to [0, width].
    var fadeLength: CGFloat = 20.0
    {
        didSet
        {
            fadeLength = min(max(0, fadeLength), self.width)
            updateGradientLocations()
        }
    }
    
    /// Percentage to reveal. Clamped to [0, 1].
    var reveal: CGFloat = 0.0
    {
        didSet
        {
            reveal = min(max(0, reveal), 1)
            performTransaction {
                gradient.x = (reveal - 1) * gradient.width
            }
        }
    }
    
    override func prepare()
    {
        super.prepare()
        
        gradient.colors = [UIColor.white.cgColor, UIColor(white: 1, alpha: 0).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        titleLabel.layer.mask = gradient
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        var gradientFrame = gradient.frame
        gradientFrame.size = self.bounds.size
        gradient.frame = gradientFrame
        
        updateGradientLocations()
    }
    
    private func updateGradientLocations()
    {
        performTransaction
        {
            gradient.width = titleLabel.width + fadeLength
            gradient.locations = [NSNumber(value: Float(1 - (fadeLength / gradient.width))), 1]
        }
    }
    
    private func performTransaction(_ transaction: (() -> Void))
    {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        transaction()
        
        CATransaction.commit()
    }
}
