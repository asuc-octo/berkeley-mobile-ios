
import UIKit
import Firebase

fileprivate let kResourceTileID = "ResourceTile"

/**
 * 
 */
class ResourceGroupCell: UITableViewCell, RequiresData, UICollectionViewDataSource, UICollectionViewDelegate
{
    typealias SelectionHandler = (Resource) -> Void
    
    // Data
    private var resources: [Resource]!
    private var selectionHandler: SelectionHandler?

    // UI
    @IBOutlet private weak var groupLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    
    /// Configure the collectionView.
    override func awakeFromNib()
    {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
    }
    
    
    // ========================================
    // MARK: - RequiresData
    // ========================================
    typealias DataType = (name: String, resources: [Resource], handler: SelectionHandler?)
    
    /**
     * Set the name, dining halls, and selection callback handler.
     * The carousel collectionView is reloaded.
     */
    public func setData(_ data: DataType)
    {
        self.resources = data.resources
        self.groupLabel.text = data.name
        self.groupLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightBold)
        
        self.selectionHandler = data.handler
        
        self.collectionView.reloadData()
    }
    
    
    // ========================================
    // MARK: - UICollectionViewDataSource
    // ========================================
    
    /// Carousel only has 1 section.
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    /// Return the number of tiles in the group.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        var count = 0
        if (groupLabel.text == "Gym Classes") {
            for res in resources {
                if ((res as! GymClass).start_time == nil) {
                    count += 1
                }
            }
            return count
        }
        return resources.count
    }
    
    /// Get a ResourceTile and pass it the corresponding Resource.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kResourceTileID, for: indexPath) as! ResourceTile
        cell.setData( self.resources[indexPath.item] )
        
        return cell
    }
    
    
    
    // ========================================
    // MARK: - UICollectionViewDelegate
    // ========================================
    
    /// When a ResourceTile is selected (tapped), call the selectionHandler with the Resource.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.selectionHandler?( self.resources[indexPath.item] )
        let some_type = type(of: self.resources[indexPath.item])
        if (some_type == berkeleyMobileiOS.Library.self) {
            Analytics.logEvent("opened_library", parameters: ["library" : self.resources[indexPath.item].name])
            
        } else if (some_type == berkeleyMobileiOS.CampusResource.self) {
            Analytics.logEvent("opened_resource", parameters: ["resource" : self.resources[indexPath.item].name])
        } else if (some_type == berkeleyMobileiOS.DiningHall.self) {
//            Analytics.logEvent("opened_food", parameters: nil)
            
        } else if (some_type == berkeleyMobileiOS.Gym.self) {
            Analytics.logEvent("opened_gym", parameters: ["gym" : self.resources[indexPath.item].name])
            
        } else if (some_type == berkeleyMobileiOS.GymClass.self) {
            Analytics.logEvent("opened_gym_class", parameters: ["gym class category" : self.resources[indexPath.item].name])
        } else {
            print("Error")
        }
    }
}
