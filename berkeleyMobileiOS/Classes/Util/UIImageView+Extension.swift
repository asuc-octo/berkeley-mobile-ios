
import UIKit
import Foundation

import Alamofire


extension UIImageView
{
    func load(resource: Resource)
    {
        let url = resource.imageURL
        if url == nil {
            return
        }
    
        Alamofire.request(url!).responseData
        { response in
            
            guard let data = response.data else {
                //network error
                return
            }
            
            guard let image = UIImage(data: data) else {
                // image dat error
                return
            }
            
            DispatchQueue.main.async {
                self.image = image
                resource.image = image
            }
        }
    }
}
