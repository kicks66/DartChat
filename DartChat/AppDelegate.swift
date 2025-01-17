//
//  AppDelegate.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 23/08/2021.
//

import UIKit
import CoreData
import Amplitude

/// Default class generated by iOS apps. This is where apps and windows lifecycles are maintained.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var notificationCenter: UNUserNotificationCenter?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Amplitude.instance().trackingSessionEvents = true
        Amplitude.instance().initializeApiKey("dbd0a05e65910e337308bfe92064d019")
        
        // Set UserNotificationDelegate to handle when user taps notification
        notificationCenter = UNUserNotificationCenter.current()
        notificationCenter?.delegate = self
        
        return true
    }

    /// Default function which is not in use but the `AppDelegate` must support.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    /// Default function which is not in use but the `AppDelegate` must support.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    
    /// Get the persistent storage `CoreData` container.
    ///
    /// Lazily loaded as we load it just-in-time.
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    /// Saved to the `CoreData` container. A simple helper function used around the app.
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Called when user taps a notification and app is in the background.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        #warning("Implement hanlding and deep links once a link is tapped")
    }
}
