//
//  AppDelegate.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/4/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import UIKit

//var token = UserDefaults.standard.value(forKey: MyUserDefaultKeys.token) as? String ?? ""
//var tokenIssuer = "1"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let myViewController = UIViewController()
    
    func createSpliteViewController() {
        
        window?.rootViewController = UINavigationController(rootViewController: MyChatViewController())
//        window!.rootViewController = UINavigationController(rootViewController: splitViewController)
    }
    
    func loginIfNedded() {
        
        // 1-0 check if user had login befor (there is some value inside UserDefaults)
        // 1-1 if toke expiration has passed, call refreshToken function to get new token
        // 2- if user didn't login yet, push him to the sso login page
        if let token = UserDefaults.standard.value(forKey: MyUserDefaultKeys.token) as? String {
            if (token != "") && (token != " ") {
                if let tokenExTime = UserDefaults.standard.value(forKey: MyUserDefaultKeys.expireTokenTime) as? Int {
                    if (Date().secondsSince1970 > tokenExTime) {
                        // call referesh token!
                        refereshToken()
                    } else {
//                        window?.rootViewController = myViewController
//                        self.createMenuView()
                        refereshToken()
                    }
                }
            }
        } else {
            let loginPage = LoginViewController()
            window?.rootViewController = loginPage
//            window.present(loginPage, animated: true, completion: nil)
        }
    }
    func refereshToken() {
        window?.rootViewController = myViewController
        let refreshToken = UserDefaults.standard.value(forKey: MyUserDefaultKeys.refreshToken) as! String
        let codeVerifier = UserDefaults.standard.value(forKey: MyUserDefaultKeys.codeVerifier) as! String
        
        Networking.sharedInstance.getTokenWithRefreshToken(refreshToken:    refreshToken,
                                                           codeVerifier:    codeVerifier)
        { (result) in
            if result == true {
                DispatchQueue.main.async {
                    self.createSpliteViewController()
                }
            }
        }
        
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
//        window?.rootViewController = MyChatViewController()
        window?.rootViewController = UINavigationController(rootViewController: MyChatViewController())
        
//        loginIfNedded()
        
//        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.codeVerifier)
//        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.expires_in)
//        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.expireTokenTime)
//        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.refreshToken)
//        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.token)
//        UserDefaults.standard.setValue(nil, forKey: MyUserDefaultKeys.tokenIssuer)
        
        return true
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

