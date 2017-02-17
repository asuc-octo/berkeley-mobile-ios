
import UIKit

fileprivate let kPanelMargin: CGFloat = 16.0
fileprivate let kLargeMargin: CGFloat = 8.0
fileprivate let kSmallMargin: CGFloat = 4.0
fileprivate let kLabelHeight: CGFloat = 20.0

/**
 * Rectangular panel that contains a main and two sub labels.
 */
class InfoPanel: UIView
{
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var text1Label: UILabel!
    @IBOutlet var text2Label: UILabel!
    
    private let curtain = UIView()
    private let curtainGradient = CAGradientLayer()
    
    
    /// Title (main text) of the panel.
    var title: String?
    {
        get { return self.titleLabel.text }
        set { self.titleLabel.text = newValue }
    }
    
    /// Upper subtext of the panel.
    var text1: String?
    {
        get { return self.text1Label.text }
        set { self.text1Label.text = newValue }
    }
    
    /// Lower subtext of the panel.
    var text2: String?
    {
        get { return self.text2Label.text }
        set { self.text2Label.text = newValue }
    }
    
    var curtainHeight: CGFloat
    {
        get { return curtain.height }
        set { curtain.height = max(0, newValue) }
    }
    
    
    ///
    override func awakeFromNib()
    {
        guard let color = self.backgroundColor else {
            return
        }

        self.clipsToBounds = true
        self.addSubview(curtain)
        
        curtain.frame = CGRect.zero
        curtain.clipsToBounds = false
        curtain.backgroundColor = color
        curtain.layer.shouldRasterize = true
//        curtain.layer.addSublayer(curtainGradient)
        
//        curtainGradient.shouldRasterize = true
//        curtainGradient.colors = [color.cgColor, color.withAlphaComponent(0).cgColor]
    }
    
    
    /// Returns a size with the same given with but constant height for the labels and paddings.
    override func sizeThatFits(_ size: CGSize) -> CGSize 
    {
        let height = (2 * kPanelMargin) + (3 * kLargeMargin) + kLargeMargin + kSmallMargin
        return CGSize(width: size.width, height: height)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let labelWidth = self.width - (2 * kPanelMargin)
        let labelSize = CGSize(width: labelWidth, height: kLabelHeight)
        
        var labelOrigin = CGPoint(x: kPanelMargin, y: kPanelMargin)
        self.titleLabel.frame = CGRect(origin: labelOrigin, size: labelSize)
        
        labelOrigin.y = self.titleLabel.frame.maxY + kSmallMargin
        self.text1Label.frame = CGRect(origin: labelOrigin, size: labelSize)
        
        labelOrigin.y = self.text1Label.frame.maxY + kSmallMargin
        self.text2Label.frame = CGRect(origin: labelOrigin, size: labelSize)
        
        
        // Curtain
        curtain.frame = CGRect(x: 0, y: 0, width: self.width, height: curtain.height)
//        curtainGradient.frame = CGRect(x: 0, y: curtain.height, width: curtain.width, height: 10)
    }
}
