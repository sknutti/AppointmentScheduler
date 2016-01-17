//
//  AppDelegate.swift
//  AppointmentScheduler
//
//  Created by Scott Knutti on 1/14/16.
//  Copyright © 2016 Scott Knutti. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        generateSampleData()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func generateSampleData() {
        let context = CoreDataStackManager.sharedInstance().managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Member")
        var memberCount: Int
        
        do {
            memberCount = try context.executeFetchRequest(fetchRequest).count
        } catch _ {
            memberCount = 0
        }
        
        if memberCount == 0 {
            RandomUserClient.sharedInstance.fetchRandomUser() { JSONResult, error in
                dispatch_async(dispatch_get_main_queue()) {
                    if let results = JSONResult.objectForKey("results")![0] {
                        let user = results["user"]!
                        let profileImagePath = user!.objectForKey("picture")!["thumbnail"] as? String
                        RandomUserClient.sharedInstance.downloadImage(profileImagePath!) { data, error in
                            dispatch_async(dispatch_get_main_queue()) {
                                let member = Member(dictionary: ["memberName": "Kevin Bacon", "memberPhone": "555-867-5309", "memberEmail": "kevin@bacon.com", "isInterviewer": 0], context: context)
                                member.profileImage = data
                            }
                        }
                    }
                }
            }
            RandomUserClient.sharedInstance.fetchRandomUser() { JSONResult, error in
                dispatch_async(dispatch_get_main_queue()) {
                    if let results = JSONResult.objectForKey("results")![0] {
                        let user = results["user"]!
                        let profileImagePath = user!.objectForKey("picture")!["thumbnail"] as? String
                        RandomUserClient.sharedInstance.downloadImage(profileImagePath!) { data, error in
                            dispatch_async(dispatch_get_main_queue()) {
                                let member = Member(dictionary: ["memberName": "Fred Flintstone", "memberPhone": "555-867-5309", "memberEmail": "fred@slateco.com", "isInterviewer": 1], context: context)
                                member.profileImage = data
                            }
                        }
                    }
                }
            }
            RandomUserClient.sharedInstance.fetchRandomUser() { JSONResult, error in
                dispatch_async(dispatch_get_main_queue()) {
                    if let results = JSONResult.objectForKey("results")![0] {
                        let user = results["user"]!
                        let profileImagePath = user!.objectForKey("picture")!["thumbnail"] as? String
                        RandomUserClient.sharedInstance.downloadImage(profileImagePath!) { data, error in
                            dispatch_async(dispatch_get_main_queue()) {
                                let member = Member(dictionary: ["memberName": "Barney Rubble", "memberPhone": "555-867-5309", "memberEmail": "barney@slateco.com", "isInterviewer": 1], context: context)
                                member.profileImage = data
                            }
                        }
                    }
                }
            }
            RandomUserClient.sharedInstance.fetchRandomUser() { JSONResult, error in
                dispatch_async(dispatch_get_main_queue()) {
                    if let results = JSONResult.objectForKey("results")![0] {
                        let user = results["user"]!
                        let profileImagePath = user!.objectForKey("picture")!["thumbnail"] as? String
                        RandomUserClient.sharedInstance.downloadImage(profileImagePath!) { data, error in
                            dispatch_async(dispatch_get_main_queue()) {
                                let member = Member(dictionary: ["memberName": "Wilma Flintstone", "memberPhone": "555-867-5309", "memberEmail": "wilma@slateco.com", "isInterviewer": 0], context: context)
                                member.profileImage = data
                            }
                        }
                    }
                }
            }
            RandomUserClient.sharedInstance.fetchRandomUser() { JSONResult, error in
                if let results = JSONResult.objectForKey("results")![0] {
                    let user = results["user"]!
                    let profileImagePath = user!.objectForKey("picture")!["thumbnail"] as? String
                    RandomUserClient.sharedInstance.downloadImage(profileImagePath!) { data, error in
                        let member = Member(dictionary: ["memberName": "Betty Rubble", "memberPhone": "555-867-5309", "memberEmail": "betty@slateco.com", "isInterviewer": 0], context: context)
                        member.profileImage = data
                    }
                }
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
}

