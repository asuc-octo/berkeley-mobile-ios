
import UIKit

fileprivate let kImageNormal = "heart_emtpy"
fileprivate let kImageSelected = "heart_filled"

/**
 * A square button that toggles between normal and selected images.
 * Whenever the state changes, the handler is called with the new state.
 *
 * If a different size is specified through setData(), 
 * insets are adjusted without changing the touch area.
 */
class SaveButton: UIButton, RequiresData
{
    private var imageSize: CGFloat?
    private var stateHandler: ((Bool) -> Void)?

    
    // ========================================
    // MARK: - Init
    // ========================================
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        configure()
    }
    
    /**
     * Configure the button to use normal and selected images,
     * and call toggle() when pressed.
     */
    private func configure()
    {
        self.setImage(UIImage(named: kImageNormal), for: .normal)
        self.setImage(UIImage(named: kImageSelected), for: .selected)
        self.addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = (imageSize: CGFloat?, stateHandler: ((Bool) -> Void)?)
    
    /**
     * imageSize changes the image size without changing the button size.
     * stateHandler is called when selected state is toggled.
     * Specify either as nil to reset it. 
     */
    func setData(_ data: DataType)
    {
        self.imageSize = data.imageSize
        self.stateHandler = data.stateHandler
    }
    
    
    /// Adjust the image insets according to the specified imageSize, if set.
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        let size = self.imageSize ?? self.height
        let inset = round((self.height - size) / 2)
        self.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset)
    }
    
    
    /// Toggle the selected state and call the handler if there is one.
    func toggle()
    {
        self.isSelected = !self.isSelected
        self.stateHandler?(self.isSelected)
    }
}
