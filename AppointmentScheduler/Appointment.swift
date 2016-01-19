//
//  Appointment.swift
//  AppointmentScheduler
//
//  Created by Scott Knutti on 1/15/16.
//  Copyright © 2016 Scott Knutti. All rights reserved.
//

import Foundation
import CoreData

class Appointment: NSManagedObject {
    @NSManaged var interviewTime: NSDate?
    @NSManaged var interviewer: String?
    @NSManaged var location: String?
    @NSManaged var isCompleted: NSNumber
    @NSManaged var member: Member?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Appointment", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        interviewTime = dictionary["interviewTime"] as? NSDate
        interviewer = dictionary["interviewer"] as? String
        location = dictionary["location"] as? String
        isCompleted = dictionary["isCompleted"]! as! NSNumber
    }
    
    func delete() {
        managedObjectContext?.deleteObject(self)
        
        dispatch_async(dispatch_get_main_queue()) {
            do {
                try self.managedObjectContext?.save()
            } catch {
                print("Error deleting \(error)")
            }
        }
    }
}
