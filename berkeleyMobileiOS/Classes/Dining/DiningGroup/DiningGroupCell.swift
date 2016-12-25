
import UIKit

fileprivate let kLocationTileID = "LocationTile"

/**
 * GroupCell shows a carousel of locations as a CollectionView of LocationTiles.
 *  
 */
class DiningGroupCell: UITableViewCell, RequiresData, UICollectionViewDataSource, UICollectionViewDelegate
{
    typealias HandlerType = (DiningHall) -> Void

    private var halls: [DiningHall]!
    private var selectionHandler: HandlerType?
    
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
    typealias DataType = (name: String, halls: [DiningHall], selectionHandler: HandlerType?)
    
    public func setData(_ data: DataType)
    {
        self.halls = data.halls
        self.groupLabel.text = data.name
        self.selectionHandler = data.selectionHandler
        
        self.collectionView.reloadData()
    }
    
    
    // ========================================
    // MARK: - UICollectionViewDataSource
    // ========================================
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return halls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kLocationTileID, for: indexPath) as! LocationTile
        cell.setData(halls[indexPath.item])
        
        return cell
    }
    
    
    // ========================================
    // MARK: - UICollectionViewDelegate
    // ========================================
    
    /// When a LocationTile is selected (tapped), call the selectionHandler with the DinigHall.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.selectionHandler?( self.halls[indexPath.item] )
    }
}
