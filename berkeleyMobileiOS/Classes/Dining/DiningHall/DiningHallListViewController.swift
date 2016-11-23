//
//  DiningHallListViewController.swift
//  BerkeleyMobile iOS
//
//  Bohui Moon (@bohuim) | 2016.10.14
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit

private let DiningHallCellID = "DiningHallCell"
private let DiningHallSegue = "DiningHallSegue"

fileprivate let kColorNavy = UIColor(red: 23/255.0, green: 85/255.0, blue: 122/255.0, alpha: 1)


/**
 * ViewController that shows the list of all DiningHalls.
 */
class DiningHallListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    // Data
    var halls: [DiningHall] = []

    // UI
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    var tableView: UITableView!
    var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - UIViewController
    /**
     * Called after view is loaded.
     * Configure navbar, add the tableView, and load DiningHall data.
     */
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let screen = UIScreen.main.bounds
        let screenSize = screen.size
        
        // Navbar settings.
        let navbar = self.navigationController!.navigationBar
        self.navigationController!.statusBarStyle = .lightContent
        navbar.barStyle = .black
        navbar.isTranslucent = false
        navbar.tintColor = UIColor.white
        navbar.barTintColor = kColorNavy
        navbar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
        
        // Add tableView.
        self.tableView = UITableView(frame: screen, style: .plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = DiningHallCell.height
        self.tableView.register(DiningHallCell.self, forCellReuseIdentifier: DiningHallCellID)
        self.view.addSubview(self.tableView)
        
        // Activity Indicator
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.activityIndicator.center = CGPoint(x: screenSize.width/2, y: screenSize.height * 1/3)
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
        
        
        // Fetch data.
        self.activityIndicator.startAnimating()
        DiningDataSource.fetchDiningHalls()
        { (_ halls: [DiningHall]?) in
        
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        
            if halls.isNil
            {
                // Show some error screen.
                print("[ERROR @ DiningHallTableViewController] failed to fetch DiningHalls")
                return
            }
            
            self.halls = halls!
            
            // Reload in main thread.
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
        setStatusBarStyle(self.preferredStatusBarStyle)
    }
    
    
    // ========================================
    // MARK: - UITableViewDataSource    
    // ========================================
    
    // Return the number of dining hall locations.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.halls.count
    }
    
    // Set the corresponding DiningHall for the cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiningHallCellID) as! DiningHallCell
        cell.diningHall = halls[indexPath.row]
        
        return cell
    }
    

    // MARK: - UITableViewDelegate
    /**
     * When a DiningHallCell is selected, perform segue to a DiningHallVC with the corresponding DiningHall object.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: DiningHallSegue, sender: halls[indexPath.row])
    }
    
    
    // MARK: - Navigation
    /**
     * Pass the DiningHall data to the DiningHallVC. 
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == DiningHallSegue,
        let diningHall   = sender as? DiningHall,
        let diningHallVC = segue.destination as? DiningHallViewController
        {
            diningHallVC.setData(diningHall)
        }
    }
}
