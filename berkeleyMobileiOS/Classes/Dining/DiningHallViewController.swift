
import UIKit
import Material

/**
 * ViewController for a specific DiningHall.
 */
class DiningHallViewController: UIViewController
{
    // Data
    var diningHall: DiningHall? = nil
    
    // UI
    var backdrop: UIImageView = UIImageView()
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        
    }
    
    func backPressed()
    {
        
    }
}
