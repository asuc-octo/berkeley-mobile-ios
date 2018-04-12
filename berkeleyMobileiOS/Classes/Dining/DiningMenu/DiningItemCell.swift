
import UIKit
import Firebase

fileprivate let kCellPadding: CGFloat = 12.0
fileprivate let kContentHeight: CGFloat = 44.0


/**
 * TableViewCell to represent a single DiningMenu item. 
 */
class DiningItemCell: UITableViewCell, RequiresData, ToggleButtonDelegate
{
    // Data
    private var item: DiningItem!

    // UI
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var dietImageView1: UIImageView!
    @IBOutlet weak var dietImageView2: UIImageView!
    @IBOutlet weak var dietImageView3: UIImageView!
    @IBOutlet weak var dietImageView4: UIImageView!
    @IBOutlet weak var dietImageView5: UIImageView!
    @IBOutlet weak var dietImageView6: UIImageView!
    @IBOutlet weak var dietImageView7: UIImageView!
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = DiningItem
    
    /// Receive the DiningItem to represent, whehter it's already favorited, and an optional callback. 
    func setData(_ item: DataType)
    {
        self.item = item
        
        var str = item.name
        
        if str.characters.contains("$"){
            
            
            let start = str.index(str.startIndex, offsetBy: 0)
            let end = str.index(str.endIndex, offsetBy: -5)
            let range = start..<end
        
        
        
            let start2 = str.index(str.endIndex, offsetBy: -5)
            let end2 = str.index(str.endIndex, offsetBy: -0)
            let range2 = start2..<end2
        
            let nameString = str[range]
        
            let costString = str[range2]
        
        
            nameLabel.text = nameString
        
            costLabel.text = costString.trimmingCharacters(in: .whitespaces)
            
        } else {
            nameLabel.text = str
            costLabel.isHidden = true
        }
        
        
        
        
        favoriteButton.isSelected = item.isFavorited
        
        let restrictions = item.restrictions
        
        let screenWidth = UIScreen.main.bounds.width
        
        // word wrapping dependent on number of images
        switch restrictions.count {
        case 7 :
            width = 193
        case 6 :
            width = 212
        case 5 :
            width = 231
        case 4 :
            width = 250
        case 3 :
            width = 269
        case 2 :
            width = 288
        case 1 :
            width = 306
        default:
            width = 313
        }
        
        // programmatically set constraints for word wrapping
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = NSLayoutConstraint(item: nameLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: width)
        self.contentView.addConstraint(widthConstraint)
        
        
        
        // add diet restrictions to imageviews
        let dietImages: [UIImageView] = [dietImageView1, dietImageView2, dietImageView3, dietImageView4, dietImageView5, dietImageView5, dietImageView6]
        if (restrictions.count > 0) {
            
            for index in 0...6 {
                let dietImageView = dietImages[index]
                
                if (index <= restrictions.count - 1) {
                    let r = restrictions[index]
                    
                    // some cases are not yet supplied by back-end
                    switch r {
                    case "Contains Alcohol" :
                        dietImageView.image = UIImage(named: "ALCOHOL")
                    case "Egg" :
                        dietImageView.image = UIImage(named: "EGG")
                    case "Fish" :
                        dietImageView.image = UIImage(named: "FISH")
                    case "Contains Gluten" :
                        dietImageView.image = UIImage(named: "GLUTEN")
                    case "Halal" :
                        dietImageView.image = UIImage(named: "HALAL")
                    case "Kosher" :
                        dietImageView.image = UIImage(named: "KOSHER")
                    case "Milk" :
                        dietImageView.image = UIImage(named: "MILK")
                    case "Peanuts" :
                        dietImageView.image = UIImage(named: "PEANUTS")
                    case "Contains Pork" :
                        dietImageView.image = UIImage(named: "PORK")
                    case "Sesame" :
                        dietImageView.image = UIImage(named: "SESAME")
                    case "Shellfish" :
                        dietImageView.image = UIImage(named: "SHELLFISH")
                    case "Soybeans" :
                        dietImageView.image = UIImage(named: "SOYBEAN")
                    case "Tree Nuts" :
                        dietImageView.image = UIImage(named: "TREENUTS")
                    case "Vegan Option" :
                        dietImageView.image = UIImage(named: "VEGAN")
                    case "Vegetarian Option" :
                        dietImageView.image = UIImage(named: "VEGETARIAN")
                    case "Wheat" :
                        dietImageView.image = UIImage(named: "WHEAT")
                    default:
                        dietImageView.image = nil
                    }
                } else {
                    dietImageView.image = nil
                }
                
            }
        }
        
        
    }
    
    
    
    // ========================================
    // MARK: - ToggleButtonDelegate
    // ========================================
    /**
     * When the favoriteButton is toggled, update the FavoriteStore.
     * 
     * - Note:
     *  Ideally updating the Store should be done in a controller, 
     *  but because that requires an extra layer of delegation/callback,
     *  opted to include the Store write action here.
     */
    func buttonDidToggle(_ button: ToggleButton)
    {
        item.isFavorited = button.isSelected
        FavoriteStore.shared.update(item)
        Analytics.logEvent("favorited_food_item", parameters: ["food_item" : item.name])

    }
}
