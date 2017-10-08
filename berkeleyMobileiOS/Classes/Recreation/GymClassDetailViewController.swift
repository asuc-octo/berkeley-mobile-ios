//
//  GymClassDetailViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 3/12/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit
import RealmSwift

class GymClassDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var classCategories: [GymClassCategory]?
    var favoriteClassCategories = [String]()
    var realm = try! Realm()

    @IBOutlet var gymClassCategoryTableView: UITableView!
    
    
    // MARK: - IBInitializable
    typealias IBComponent = GymDetailViewController
    
    static var componentID: String { return className(IBComponent.self) }
    
    static func fromIB() -> IBComponent {
        return UIStoryboard.gym.instantiateViewController(withIdentifier: self.componentID) as! IBComponent
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAndSetFavoriteGymClassCategories()
        gymClassCategoryTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "gymClassCategory") as! GymClassCategoryCell
        let gymClassCategory = classCategories?[indexPath.row]
        cell.gymClassCategory.text = gymClassCategory?.name
        
        //For gym status (open/closed)
        cell.gymClassCategoryStatus.text = "Open"
        cell.gymClassCategoryStatus.textColor = UIColor.green
        
        
        // For favoriting
        if (gymClassCategory?.isFavorited == true) {
            cell.favoriteButton.setImage(UIImage(named:"heart-filled"), for: .normal)
        } else {
            cell.favoriteButton.setImage(UIImage(named:"heart"), for: .normal)
        }
        cell.favoriteButton.tag = indexPath.row
        cell.favoriteButton.addTarget(self, action: #selector(self.toggleGymClassCategoryFavoriting(sender:)), for: .touchUpInside)

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "GymClassDetailSegue", sender: indexPath.row)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (classCategories?.count)!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination
        
        if let vc = destination as? GymClassViewController
        {
            vc.classType = classCategories?[sender as! Int]
        }
        
    }
    
    //Favoriting
    func toggleGymClassCategoryFavoriting(sender: UIButton) {
        
        let row = sender.tag
        let selectedGymClassCategory = self.classCategories?[row]
        selectedGymClassCategory?.isFavorited = !(selectedGymClassCategory?.isFavorited)!
        self.gymClassCategoryTableView.reloadData()
        
        //Realm adding and deleting favorite campus resources
        let favGymClassCategory = FavoriteGymClassCategory()
        favGymClassCategory.name = (selectedGymClassCategory?.name)!
        
        if (selectedGymClassCategory?.isFavorited)! {
            try! realm.write {
                realm.add(favGymClassCategory)
            }
        } else {
            let GymClassCategorys = realm.objects(FavoriteGymClassCategory.self)
            for GymClassCategory in GymClassCategorys {
                if GymClassCategory.name == selectedGymClassCategory?.name {
                    try! realm.write {
                        realm.delete(GymClassCategory)
                    }
                }
            }
        }
        
    }
    
    func getAndSetFavoriteGymClassCategories() {
        self.favoriteClassCategories.removeAll()
        let GymClassCategorys = realm.objects(FavoriteGymClassCategory.self)
        for GymClassCategory in GymClassCategorys {
            self.favoriteClassCategories.append(GymClassCategory.name)
        }
        
        for category in self.classCategories! {
            if self.favoriteClassCategories.contains(category.name) {
                category.isFavorited = true
            }
        }
    }

    
    
}

class FavoriteGymClassCategory: Object {
    dynamic var name = ""
}
