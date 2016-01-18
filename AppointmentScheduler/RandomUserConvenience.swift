//
//  RandomUserConvenience.swift
//  AppointmentScheduler
//
//  Created by Scott Knutti on 1/18/16.
//  Copyright © 2016 Scott Knutti. All rights reserved.
//

import CoreData
import UIKit

extension RandomUserClient {
    
    func generateSampleData(activityIndicatorView: UIActivityIndicatorView) {
        let context = CoreDataStackManager.sharedInstance().managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Member")
        var memberCount: Int = 0
        
        do {
            memberCount = try context.executeFetchRequest(fetchRequest).count
        } catch _ {
            memberCount = 0
        }

        if memberCount == 0 {
            RandomUserClient.sharedInstance.fetchRandomUser() { JSONResult, error in
                if (JSONResult != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let results = JSONResult.objectForKey("results")![0] {
                            let user = results["user"]!
                            let profileImagePath = user!.objectForKey("picture")!["thumbnail"] as? String
                            RandomUserClient.sharedInstance.downloadImage(profileImagePath!) { data, error in
                                dispatch_async(dispatch_get_main_queue()) {
                                    let member = Member(dictionary: ["memberName": "Kevin Bacon", "memberPhone": "555-867-5309", "memberEmail": "kevin@bacon.com", "isInterviewer": 0], context: context)
                                    let pieces = profileImagePath!.componentsSeparatedByString("/")
                                    member.profileImagePath = pieces[pieces.count-1]
                                    member.profileImage = UIImage(data: data)
                                }
                            }
                        }
                    }
                }
            }
            RandomUserClient.sharedInstance.fetchRandomUser() { JSONResult, error in
                if (JSONResult != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let results = JSONResult.objectForKey("results")![0] {
                            let user = results["user"]!
                            let profileImagePath = user!.objectForKey("picture")!["thumbnail"] as? String
                            RandomUserClient.sharedInstance.downloadImage(profileImagePath!) { data, error in
                                dispatch_async(dispatch_get_main_queue()) {
                                    let member = Member(dictionary: ["memberName": "Fred Flintstone", "memberPhone": "555-867-5309", "memberEmail": "fred@slateco.com", "isInterviewer": 1], context: context)
                                    let pieces = profileImagePath!.componentsSeparatedByString("/")
                                    member.profileImagePath = pieces[pieces.count-1]
                                    member.profileImage = UIImage(data: data)
                                }
                            }
                        }
                    }
                }
            }
            RandomUserClient.sharedInstance.fetchRandomUser() { JSONResult, error in
                if (JSONResult != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let results = JSONResult.objectForKey("results")![0] {
                            let user = results["user"]!
                            let profileImagePath = user!.objectForKey("picture")!["thumbnail"] as? String
                            RandomUserClient.sharedInstance.downloadImage(profileImagePath!) { data, error in
                                dispatch_async(dispatch_get_main_queue()) {
                                    let member = Member(dictionary: ["memberName": "Barney Rubble", "memberPhone": "555-867-5309", "memberEmail": "barney@slateco.com", "isInterviewer": 1], context: context)
                                    let pieces = profileImagePath!.componentsSeparatedByString("/")
                                    member.profileImagePath = pieces[pieces.count-1]
                                    member.profileImage = UIImage(data: data)
                                }
                            }
                        }
                    }
                }
            }
            RandomUserClient.sharedInstance.fetchRandomUser() { JSONResult, error in
                if (JSONResult != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let results = JSONResult.objectForKey("results")![0] {
                            let user = results["user"]!
                            let profileImagePath = user!.objectForKey("picture")!["thumbnail"] as? String
                            RandomUserClient.sharedInstance.downloadImage(profileImagePath!) { data, error in
                                dispatch_async(dispatch_get_main_queue()) {
                                    let member = Member(dictionary: ["memberName": "Wilma Flintstone", "memberPhone": "555-867-5309", "memberEmail": "wilma@slateco.com", "isInterviewer": 0], context: context)
                                    let pieces = profileImagePath!.componentsSeparatedByString("/")
                                    member.profileImagePath = pieces[pieces.count-1]
                                    member.profileImage = UIImage(data: data)
                                }
                            }
                        }
                    }
                }
            }
            RandomUserClient.sharedInstance.fetchRandomUser() { JSONResult, error in
                if (JSONResult != nil) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if let results = JSONResult.objectForKey("results")![0] {
                            let user = results["user"]!
                            let profileImagePath = user!.objectForKey("picture")!["thumbnail"] as? String
                            RandomUserClient.sharedInstance.downloadImage(profileImagePath!) { data, error in
                                dispatch_async(dispatch_get_main_queue()) {
                                    let member = Member(dictionary: ["memberName": "Betty Rubble", "memberPhone": "555-867-5309", "memberEmail": "betty@slateco.com", "isInterviewer": 0], context: context)
                                    let pieces = profileImagePath!.componentsSeparatedByString("/")
                                    member.profileImagePath = pieces[pieces.count-1]
                                    member.profileImage = UIImage(data: data)
                                    activityIndicatorView.stopAnimating()
                                }
                            }
                        }
                    }
                }
            }
            
            CoreDataStackManager.sharedInstance().saveContext()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }
}