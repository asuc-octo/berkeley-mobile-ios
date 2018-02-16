//
//  GymClassDetailViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 3/12/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit
import RealmSwift

class GymClassDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ResourceDetailProvider, IBInitializable {
    var image: UIImage?
    
    
    static func newInstance() -> ResourceDetailProvider {
        return fromIB()
    }
    
    var resource: Resource {
        get
        {
            return gymClass
        }
        set
        {
            if viewIfLoaded == nil, gymClass == nil, let newClass = newValue as? GymClass {
                gymClass = newClass
                title = gymClass.class_type
            }
            
        }
    }
    
    var viewController: UIViewController {
        return self
    }
    
    var text1: String? {
        return nil
    }
    
    var text2: String? {
        return nil
    }
    
    var imageURL: URL? {
        return gymClass?.imageURL
    }
    
    var buttons: [UIButton] = []
    
    var resetOffsetOnSizeChanged = false
    
    var contentSizeChangeHandler: ((ResourceDetailProvider) -> Void)? {
        get { return nil }
        set {}
    }
    
    var contentSize: CGSize {
        let width = self.viewController.view.width
        let height = self.viewController.view.height
        return CGSize(width: width, height: height)
    }
    
    var contentOffset: CGPoint {
        get { return CGPoint.zero }
        set {}
    }
    
    func setContentOffset(_ offset: CGPoint, animated: Bool) {}
    
    var gymClass : GymClass!
    var classCategories: [GymClassCategory]?

    var favoriteClassCategories = [String]()
    var realm = try! Realm()

    @IBOutlet var gymClassCategoryTableView: UITableView!
    
    
    // MARK: - IBInitializable
    typealias IBComponent = GymClassDetailViewController
    
    static var componentID: String { return className(IBComponent.self) }
    
    static func fromIB() -> IBComponent {
        return UIStoryboard.gym.instantiateViewController(withIdentifier: self.componentID) as! IBComponent    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GymClassCategoryDataSource.fetchResources { (list) in
            self.classCategories = list as? [GymClassCategory]
            self.gymClassCategoryTableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
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

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "GymClassDetailSegue", sender: indexPath.row)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let c = classCategories {
            return (c.count)
        } else {
            return 0
        }

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
