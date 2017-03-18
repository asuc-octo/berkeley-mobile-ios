//
//  GymClassDetailViewController.swift
//  berkeleyMobileiOS
//
//  Created by Sampath Duddu on 3/12/17.
//  Copyright © 2017 org.berkeleyMobile. All rights reserved.
//

import UIKit

class GymClassDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var classCategories: [GymClassCategory]?

    @IBOutlet var gymClassCategoryTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "gymClassCategory") as! GymClassCategoryCell
        let gymClassCategory = classCategories?[indexPath.row]
        cell.gymClassCategory.text = gymClassCategory?.name

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
    
    
}
