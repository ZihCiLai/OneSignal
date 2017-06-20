//
//  AppDelegate.swift
//  MyOneSignal
//
//  Created by Lai Zih Ci on 2017/5/29.
//  Copyright © 2017年 ZihCi. All rights reserved.
//

import UIKit

import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private let appID = "d24c5012-f415-425f-935c-0a647108db48"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
            print("Message: \(payload!.body)")
            print("badge number:", payload?.badge ?? "nil")
            print("notification sound:", payload?.sound ?? "nil")
            
            if let additionalData = result!.notification.payload!.additionalData {
                print("additionalData = \(additionalData)")
                
                // DEEP LINK and open url in RedViewController
                // Send notification with Additional Data > example key: "OpenURL" example value: "https://google.com"
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let instantiateRedViewController : WebView = mainStoryboard.instantiateViewController(withIdentifier: "WebViewID") as! WebView
                instantiateRedViewController.receivedURL = additionalData["OpenURL"] as! String!
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = instantiateRedViewController
                self.window?.makeKeyAndVisible()
                
                
                if let actionSelected = payload?.actionButtons {
                    print("actionSelected = \(actionSelected)")
                }
                
                // DEEP LINK from action buttons
                if let actionID = result?.action.actionID {
                    
                    // For presenting a ViewController from push notification action button
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let actionWebView : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "WebViewID") as UIViewController
                    let actionSecond: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "SecondID") as UIViewController
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    
                    print("actionID = \(actionID)")
                    
                    if actionID == "id2" {
                        print("id2")
                        self.window?.rootViewController = actionWebView
                        self.window?.makeKeyAndVisible()
                        
                        
                    } else if actionID == "id1" {
                        print("id1")
                        self.window?.rootViewController = actionSecond
                        self.window?.makeKeyAndVisible()
                        
                    }
                }
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: true, ]
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: appID, handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
        
        // Sync hashed email if you have a login system or collect it.
        //   Will be used to reach the user at the most optimal time of day.
        // OneSignal.syncHashedEmail(userEmail
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


