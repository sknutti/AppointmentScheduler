//
//  Member.swift
//  AppointmentScheduler
//
//  Created by Scott Knutti on 1/15/16.
//  Copyright © 2016 Scott Knutti. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Member: NSManagedObject {
    @NSManaged var memberName: String
    @NSManaged var memberPhone: String
    @NSManaged var memberEmail: String
    @NSManaged var isInterviewer: NSNumber
    @NSManaged var profileImage: NSData
    @NSManaged var appointments: [Appointment]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Member", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        memberName = dictionary["memberName"]! as! String
        memberPhone = dictionary["memberPhone"]! as! String
        memberEmail = dictionary["memberEmail"]! as! String
        isInterviewer = dictionary["isInterviewer"]! as! NSNumber
    }
    
    func delete() {
        managedObjectContext?.deleteObject(self)
        
        do {
            try managedObjectContext?.save()
        } catch {
            print("Error deleting \(error)")
        }
    }
}
