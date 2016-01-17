//
//  MemberListTableViewController.swift
//  AppointmentScheduler
//
//  Created by Scott Knutti on 1/15/16.
//  Copyright © 2016 Scott Knutti. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MemberListTableViewController: UITableViewController {
    
    @IBOutlet var memberTableView: UITableView!
    var delegate: EditAppointmentViewControllerDelegate?
    var appointment: Appointment!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Member")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "memberName", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }
        
    }
}

extension MemberListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        memberTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        memberTableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            switch type {
            case .Insert:
                if let indexPath = newIndexPath {
                    memberTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                break
            case .Delete:
                memberTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                break
            case .Update:
                memberTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                break
            case .Move:
                if let indexPath = newIndexPath {
                    memberTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                if let indexPath = newIndexPath {
                    memberTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                break
            }
    }
}

extension MemberListTableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BasicCell")!
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let record = fetchedResultsController.objectAtIndexPath(indexPath) as! Member
        if (appointment.interviewer != record.memberName) {
            if (self.delegate != nil) {
                delegate?.addMember(record)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                let alert = UIAlertController(title: "Error", message: "Unable to select same person as both member and interviewer.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let record = fetchedResultsController.objectAtIndexPath(indexPath)
        
        if let name = record.valueForKey("memberName") as? String {
            cell.textLabel!.text = name
        }
    }
}
