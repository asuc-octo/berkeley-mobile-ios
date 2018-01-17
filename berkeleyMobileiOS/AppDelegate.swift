//
//  AppDelegate.swift
//  berkeleyMobileiOS
//
//  Created by Akilesh Bapu on 10/9/16.
//  Copyright © 2016 org.berkeleyMobile. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UITabBar.appearance().tintColor = UIColor(hue: 0.5583, saturation: 0.79, brightness: 0.97, alpha: 1.0)
        FirebaseApp.configure()
       
        
        
        
        // Override point for customization after application launch.
        //GMSServices.provideAPIKey("AIzaSyAsOV94_am2S5ceDbfwkMDelYGCx6AOPgU")
        //GMSPlacesClient.provideAPIKey("AIzaSyBDNjXjgVynuRh4doXKJmljkaJphtWkVB8")
        GMSServices.provideAPIKey("AIzaSyCMnCLU444kw1W7ultwW-lZ_rWNNScr6Q4")
        GMSPlacesClient.provideAPIKey("AIzaSyCMnCLU444kw1W7ultwW-lZ_rWNNScr6Q4")
        presentMainViewController()
        return true
    }
    func presentMainViewController()
    {
        var viewControllers: [UIViewController] = ResourceGroup.all.map
        {
            let resourceNav = ResourceNavigationController.fromIB()
            resourceNav.setGroup($0)
            return resourceNav
        }
        
        viewControllers.append( BearTransitNavigationController.fromIB() )
        let temp = viewControllers[0]
        viewControllers[0] = viewControllers.last!
        viewControllers[viewControllers.endIndex - 1] = temp
        let indexViewController: UIViewController  = TabBarController(viewControllers: viewControllers, selectedIndex: 0)
        indexViewController.modalTransitionStyle = .crossDissolve
        window?.rootViewController = indexViewController
//        self.present(indexViewController, animated: true, completion: nil)
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

