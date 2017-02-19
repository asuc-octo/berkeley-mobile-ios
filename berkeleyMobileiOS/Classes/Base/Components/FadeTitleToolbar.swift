
import UIKit
import Material

/**
 * `Toolbar` with a right-scroll mask over the title label, 
 * which can be controlled through the `reveal` property. 
 */
class FadeTitleToolbar: Toolbar
{
    private let gradient = CAGradientLayer()

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
    
    
    /// Length of the fade gradient. Clamped to [0, width].
    var fadeLength: CGFloat = 20.0
    {
        didSet
        {
            fadeLength = min(max(0, fadeLength), self.width)
            updateLocations()
        }
    }
    
    /// Percentage to reveal. Clamped to [0, 1].
    var reveal: CGFloat = 0.0
    {
        didSet
        {
            reveal = min(max(0, reveal), 1)
            layoutGradient()
        }
    }
    
    /// Configure the gradient layer and set it as the `titleLabel`'s mask.
    override func prepare()
    {
        super.prepare()
        
        gradient.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        titleLabel.layer.mask = gradient
    }
    
    /// Adjust the gradient frame to match view's bounds and update locations.
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        gradient.frame.size = self.bounds.size
        updateLocations()
    }
    
    /// Update gradient's locations to keep `fadeLength` consistent. 
    private func updateLocations()
    {
        CATransaction.performWithoutAnimation
        {
            gradient.width = titleLabel.width + fadeLength
            gradient.locations = [NSNumber(value: Float(1 - (fadeLength / gradient.width))), 1]
        }
    }
    
    /// Apply the `reveal` percentage to the gradient. 
    private func layoutGradient()
    {
        CATransaction.performWithoutAnimation
        {
            gradient.x = (reveal - 1) * gradient.width
        }
    }
}
