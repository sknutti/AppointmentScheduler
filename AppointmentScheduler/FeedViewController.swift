//
//  FeedViewController.swift
//  AppointmentScheduler
//
//  Created by Scott Knutti on 1/14/16.
//  Copyright © 2016 Scott Knutti. All rights reserved.
//

import UIKit
import CoreData

class FeedViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var appointmentTableView: UITableView!
    
    var delegate: EditAppointmentViewControllerDelegate?
    var appointment: Appointment!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Appointment")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "interviewTime", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        appointmentTableView.dataSource = self
        appointmentTableView.delegate = self
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

extension FeedViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        appointmentTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        appointmentTableView.endUpdates()
        appointmentTableView.reloadData()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            switch type {
            case .Insert:
                if let indexPath = newIndexPath {
                    appointmentTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                break
            case .Delete:
                appointmentTableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                break
            case .Update:
                appointmentTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                break
            case .Move:
                if let indexPath = newIndexPath {
                    appointmentTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                if let indexPath = newIndexPath {
                    appointmentTableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
                break
            }
    }
}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AppointmentCell") as! CustomAppointmentCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            let numRows = currentSection.numberOfObjects
            
            if numRows == 0 {
                let messageLabel = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
                messageLabel.text = "No appointments"
                messageLabel.textAlignment = .Center
                messageLabel.sizeToFit()
                tableView.backgroundView = messageLabel
                tableView.separatorStyle = .None
            }
            
            return numRows
        }
        return 0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let record = fetchedResultsController.objectAtIndexPath(indexPath) as! Appointment
        let editAppointmentViewController = storyboard?.instantiateViewControllerWithIdentifier("EditAppointmentVC") as! EditAppointmentViewController
        
        editAppointmentViewController.appointment = record
        
        if let popoverController = editAppointmentViewController.popoverPresentationController {
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
        }
        presentViewController(editAppointmentViewController, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let appointment = fetchedResultsController.objectAtIndexPath(indexPath) as! Appointment
        let cancel = UITableViewRowAction(style: .Normal, title: "Cancel") { action, index in
            appointment.delete()
            tableView.setEditing(false, animated: true)
        }
        cancel.backgroundColor = UIColor.redColor()
        
        let complete = UITableViewRowAction(style: .Normal, title: "Mark Completed") { action, index in
            appointment.isCompleted = 1
            CoreDataStackManager.sharedInstance().saveContext()
            tableView.setEditing(false, animated: true)
        }
        complete.backgroundColor = UIColor.blueColor()
        
        return [complete, cancel]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 158
    }
    
    func formatDate(date: NSDate, dateFormatString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormatString
        return dateFormatter.stringFromDate(date)
    }
    
    func configureCell(cell: CustomAppointmentCell, atIndexPath indexPath: NSIndexPath) {
        let record = fetchedResultsController.objectAtIndexPath(indexPath)
        
        if let member = record.valueForKey("member") as? Member {
            cell.memberLabel!.text = member.memberName
            cell.profileImage!.image = UIImage(data: member.profileImage)
        }
        
        if let interviewer = record.valueForKey("interviewer") as? String {
            cell.interviewerLabel!.text = interviewer
        }
        
        if let interviewTime = record.valueForKey("interviewTime") as? NSDate {
            cell.dateDayLabel!.text = formatDate(interviewTime, dateFormatString: "EEEE")
            cell.dateLabel!.text = formatDate(interviewTime, dateFormatString: "MMM dd, yyyy")
            cell.timeLabel!.text = formatDate(interviewTime, dateFormatString: "h:mm a")
        }
        
        if let isCompleted = record.valueForKey("isCompleted") as? Bool {
            if isCompleted {
                cell.completedImage.hidden = false
            }
        }
    }
}


