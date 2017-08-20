//
//  AppDelegate.swift
//  HelloWorld
//
//  Created by 朱力 on 2017/8/9.
//  Copyright © 2017年 朱力. All rights reserved.
//

import UIKit
import CoreData

enum ShortcutItems : String {
    case newText = "com.lzhu.HelloWorld.createTextSnippet"
    case newPhoto = "com.lzhu.HelloWorld.createPhotoSnippet"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func handleShortcut(shortcutItem: UIApplicationShortcutItem){
        switch shortcutItem.type {
            case ShortcutItems.newText.rawValue:
                let vc = self.window!.rootViewController as! ViewController
                vc.createNewTextSnippet()
            case ShortcutItems.newPhoto.rawValue:
                let vc = self.window!.rootViewController as! ViewController
                vc.createNewPhotoSnippet()
            default:
                break
        }
    }
/*
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
*/
    
    func application(_ application: UIApplication, performActionFor
        shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping(Bool) -> Void){
        let vc = self.window!.rootViewController!
        if vc.presentedViewController != nil {
            let alert = UIAlertController(title: "未完成的片段", message: "是继续还是开始一个新的片段？", preferredStyle: .alert)
            let continueAction = UIAlertAction(title: "继续", style: .default, handler: nil)
            let eraseAction = UIAlertAction(title: "删除", style: .destructive){
                (alert: UIAlertAction!) -> Void in
                vc.dismiss(animated: true, completion: nil)
                self.handleShortcut(shortcutItem: shortcutItem)
            }
            alert.addAction(continueAction)
            alert.addAction(eraseAction)
            vc.presentedViewController!.present(alert,animated: true,completion: nil)
        }else{
            handleShortcut(shortcutItem: shortcutItem)
        }
        
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
        self.saveContext()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Mark: - Core Data stack
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "SnippetData",withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordiantor: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls.last!.appendingPathComponent("SingleViewCoreData.sqlite")
        do{
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        }catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinate = self.persistentStoreCoordiantor
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinate
        return managedObjectContext
    }()
    
    // Mark: - Core Data Saving support
    func saveContext() {
        if managedObjectContext.hasChanges{
            do {
                try managedObjectContext.save()
            }catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

