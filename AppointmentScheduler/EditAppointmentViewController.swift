//
//  EditAppointmentViewController.swift
//  AppointmentScheduler
//
//  Created by Scott Knutti on 1/15/16.
//  Copyright © 2016 Scott Knutti. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol EditAppointmentViewControllerDelegate {
    func addMember(var member: Member)
    func addInterviewer(var interviewer: Member)
    func addDateTime(var date: NSDate)
}

class EditAppointmentViewController: UIViewController, UITextFieldDelegate, EditAppointmentViewControllerDelegate, UIPopoverPresentationControllerDelegate, NSFetchedResultsControllerDelegate {
    var appointment: Appointment!
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    var delegate : EditAppointmentViewControllerDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var isCompletedLabel: UILabel!
    @IBOutlet weak var isCompletedSwitch: UISwitch!
    @IBOutlet weak var memberButton: UIButton!
    @IBOutlet weak var interviewerButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var deleteButtonConstraint: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextfield.delegate = self
        
        if (appointment != nil) {
            titleLabel.text = "Edit Appointment"
            doneButton.setTitle("Update", forState: .Normal)
            deleteButton.hidden = false
            populateForm()
        } else {
            /* create a new appointment object */
            let dictionary: [String : AnyObject] = ["isCompleted": 0]
            appointment = Appointment(dictionary: dictionary, context: self.sharedContext)
            
            titleLabel.text = "Add Appointment"
            doneButton.setTitle("Save", forState: .Normal)
            deleteButton.hidden = true
            
            isCompletedLabel.hidden = true
            isCompletedSwitch.hidden = true
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if (appointment.member == nil || appointment.interviewer == nil || appointment.interviewTime == nil) {
            appointment.delete()
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if doneButtonConstraint.constant < 270 {
            doneButtonConstraint.constant += 250
        }
        view.addConstraint(doneButtonConstraint)
        
        if deleteButtonConstraint.constant < 270 {
            deleteButtonConstraint.constant += 250
        }
        view.addConstraint(deleteButtonConstraint)
    }

    func keyboardWillHide(sender: NSNotification) {
        if doneButtonConstraint.constant >= 270 {
            doneButtonConstraint.constant -= 250
        }
        view.addConstraint(doneButtonConstraint)
        
        if deleteButtonConstraint.constant >= 270 {
            deleteButtonConstraint.constant -= 250
        }
        view.addConstraint(deleteButtonConstraint)
    }
    
    func populateForm() {
        memberButton.setTitle(appointment.member?.memberName, forState: .Normal)
        interviewerButton.setTitle(appointment.interviewer, forState: .Normal)
        timeButton.setTitle(formatDate(appointment.interviewTime!), forState: .Normal)
        locationTextfield.text = appointment.location
        isCompletedSwitch.setOn(appointment.isCompleted as Bool, animated: true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
            return .None
    }
    
    @IBAction func pickMember(sender: AnyObject) {
        let memberListViewController = storyboard?.instantiateViewControllerWithIdentifier("MemberListVC") as! MemberListTableViewController
        memberListViewController.delegate = self
        memberListViewController.modalPresentationStyle = .Popover
        memberListViewController.preferredContentSize = CGSizeMake(view.frame.width, 200)
        memberListViewController.appointment = appointment
        
        if let popoverController = memberListViewController.popoverPresentationController {
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        presentViewController(memberListViewController, animated: true, completion: nil)
    }
    
    func addMember(member: Member) {
        appointment.member = member
        memberButton.setTitle(member.memberName, forState: .Normal)
    }
    
    @IBAction func pickInterviewer(sender: AnyObject) {
        let interviewerListViewController = storyboard?.instantiateViewControllerWithIdentifier("InterviewerListVC") as! InterviewerListTableViewController
        interviewerListViewController.delegate = self
        interviewerListViewController.modalPresentationStyle = .Popover
        interviewerListViewController.preferredContentSize = CGSizeMake(view.frame.width, 200)
        interviewerListViewController.appointment = appointment
        
        if let popoverController = interviewerListViewController.popoverPresentationController {
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        presentViewController(interviewerListViewController, animated: true, completion: nil)
    }
    
    func addInterviewer(interviewer: Member) {
        appointment.interviewer = interviewer.memberName
        interviewerButton.setTitle(interviewer.memberName, forState: .Normal)
    }
    
    @IBAction func pickTime(sender: AnyObject) {
        let dateTimeViewController = storyboard?.instantiateViewControllerWithIdentifier("DateTimeVC") as! DateTimeViewController
        dateTimeViewController.delegate = self
        dateTimeViewController.appointment = appointment
        
        if let popoverController = dateTimeViewController.popoverPresentationController {
            popoverController.permittedArrowDirections = .Any
            popoverController.delegate = self
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        }
        presentViewController(dateTimeViewController, animated: true, completion: nil)
    }
    
    func addDateTime(date: NSDate) {
        self.appointment.interviewTime = date
        self.timeButton.setTitle(self.formatDate(date), forState: .Normal)
    }
    
    func formatDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEE, MMM dd 'at' h:mm a"
        return dateFormatter.stringFromDate(date)
    }
    
    @IBAction func saveAppointment(sender: AnyObject) {
        if (appointment.member == nil) {
            let alert = UIAlertController(title: "Error", message: "Cannot save an appointment without a member.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else if (appointment.interviewer == nil) {
            let alert = UIAlertController(title: "Error", message: "Cannot save an appointment without an interviewer.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else if (appointment.interviewTime == nil) {
            let alert = UIAlertController(title: "Error", message: "Cannot save an appointment without an interview time.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            do {
                let record = try sharedContext.existingObjectWithID(appointment.objectID)
                let existingAppointment = record as! Appointment
                if (existingAppointment.objectID != appointment.objectID) {
                    appointment.delete()
                }
                existingAppointment.setValue(self.locationTextfield.text, forKey: "location")
                existingAppointment.setValue(self.isCompletedSwitch.on ? 1 : 0, forKey: "isCompleted")
                
                dispatch_async(dispatch_get_main_queue()) {
                    CoreDataStackManager.sharedInstance().saveContext()
                }
                if (navigationController != nil) {
                    navigationController!.popViewControllerAnimated(true)
                } else {
                    dismissViewControllerAnimated(true, completion: nil)
                }
            } catch {
                print(error)
            }
        }
    }
    
    @IBAction func deleteAppointment(sender: AnyObject) {
        dismissViewControllerAnimated(true) {
            self.appointment.delete()
        }
    }
}