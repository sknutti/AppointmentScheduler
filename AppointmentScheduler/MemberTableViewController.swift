//
//  MemberTableViewController.swift
//  AppointmentScheduler
//
//  Created by Scott Knutti on 1/14/16.
//  Copyright © 2016 Scott Knutti. All rights reserved.
//

import UIKit
import CoreData

class MemberTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet var memberTableView: UITableView!
    var headerLabel = UILabel()
    
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
        
        navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addMember:"), animated: true)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .FullScreen
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
    
    func addMember(sender: AnyObject) {
        let addMemberViewController = storyboard?.instantiateViewControllerWithIdentifier("EditMemberVC") as! EditMemberViewController
        
        if let popoverController = addMemberViewController.popoverPresentationController {
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
        }
        presentViewController(addMemberViewController, animated: true, completion: nil)
    }
}

extension MemberTableViewController: NSFetchedResultsControllerDelegate {
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
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
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
            
            let numRecords = fetchedResultsController.sections![0].numberOfObjects
            headerLabel.text = "Members (\(numRecords))"
            
            dispatch_async(dispatch_get_main_queue()) {
                CoreDataStackManager.sharedInstance().saveContext()
            }
    }
}

extension MemberTableViewController {
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderCell
        
        let numRecords = fetchedResultsController.sections![0].numberOfObjects
        
        let border = CALayer()
        let width = CGFloat(5.0)
        border.borderColor = UIColor.grayColor().CGColor
        border.frame = CGRect(x: 0, y: tableView.frame.size.height - width, width: tableView.frame.size.width, height: tableView.frame.size.height)
        
        border.borderWidth = width
        tableView.layer.addSublayer(border)
        tableView.layer.masksToBounds = true
        
        headerLabel = headerCell.headerLabel
        headerLabel.text = "Members (\(numRecords))"
        return headerCell
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MemberCell") as! CustomMemberCell!
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
        let editMemberViewController = storyboard?.instantiateViewControllerWithIdentifier("EditMemberVC") as! EditMemberViewController
        
        editMemberViewController.member = record
        
        if let popoverController = editMemberViewController.popoverPresentationController {
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
        }
        presentViewController(editMemberViewController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func configureCell(cell: CustomMemberCell, atIndexPath indexPath: NSIndexPath) {
        let record = fetchedResultsController.objectAtIndexPath(indexPath)
        
        if let name = record.valueForKey("memberName") as? String {
            cell.memberName.text = name
        }
        
        if let phone = record.valueForKey("memberPhone") as? String {
            cell.memberPhone.text = phone
        }
        
        if let email = record.valueForKey("memberEmail") as? String {
            cell.memberEmail.text = email
        }
        
        if let isInterviewer = record.valueForKey("isInterviewer") as? Bool {
            if isInterviewer {
                cell.memberIsInterviewer.image = UIImage(named: "Interviewer")
            } else {
                cell.memberIsInterviewer.image = UIImage(named: "Placeholder")
            }
        }
    }
}
