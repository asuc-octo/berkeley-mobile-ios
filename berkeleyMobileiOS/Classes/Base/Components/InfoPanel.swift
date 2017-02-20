
import UIKit

fileprivate let kPanelMargin: CGFloat = 16.0
fileprivate let kLargeMargin: CGFloat = 8.0
fileprivate let kSmallMargin: CGFloat = 4.0
fileprivate let kLabelHeight: CGFloat = 20.0

fileprivate let kFadeLength: CGFloat = 20.0
fileprivate let kFadeLengthHalf: CGFloat = kFadeLength / 2

/**
 * Rectangular panel that contains a main and two sub labels.
 * Includes a drop down curtain with gradient edge, which can be controlled through `curtainCover` property. 
 */
class InfoPanel: UIView
{
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var text1Label: UILabel!
    @IBOutlet var text2Label: UILabel!
    
    private let foreground = UIView()
    private let curtain = CAGradientLayer()
    
    /// Fixed intrinsic height for all `InfoPanel`s.
    static let panelHeight: CGFloat = (2 * kPanelMargin) + (3 * kLabelHeight) + kLargeMargin + kSmallMargin
    
    
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
    
    /// Percentage of curtain to drop down over content. Clamped to [0, height].
    var curtainCover: CGFloat = 0.0
    {
        didSet
        {
            curtainCover = min(max(0, curtainCover), self.height)
            layoutCurtain()
        }
    }
    
    
    /**
     * Configure the `curtain` and add labels to the `foreground` subview.
     * The separate forground is to apply the curtain mask only to content, excluding background color.
     */
    override func awakeFromNib()
    {
        // Curtain
        curtain.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
        curtain.startPoint = CGPoint(x: 0.5, y: 0.0)
        curtain.endPoint = CGPoint(x: 0.5, y: 1.0)
        curtain.position = CGPoint.zero
        
        let start = Float(kFadeLength / InfoPanel.panelHeight)
        curtain.locations = [0, NSNumber(value: start)]
        
        
        // Foreground
        foreground.frame = self.bounds
        foreground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        foreground.addSubview(titleLabel)
        foreground.addSubview(text1Label)
        foreground.addSubview(text2Label)
        foreground.layer.mask = curtain
        
        self.clipsToBounds = true
        self.addSubview(foreground)
    }
    
    
    /// Returns a size with the same given with but constant height for the labels and paddings.
    override func sizeThatFits(_ size: CGSize) -> CGSize 
    {
        return CGSize(width: size.width, height: InfoPanel.panelHeight)
    }
    
    /// Readjust label widths according to the view width, and re-layout the curtain.
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
        curtain.width = self.width
        curtain.height = self.height
        layoutCurtain()
    }
    
    /// Apply the `curtainCover` percentage with a slight negative offset for visual purposes.
    private func layoutCurtain()
    {
        CATransaction.performWithoutAnimation
        {
            curtain.y = curtainCover - kFadeLengthHalf
        }
    }
}
