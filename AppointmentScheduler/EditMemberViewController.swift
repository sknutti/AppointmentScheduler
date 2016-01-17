//
//  EditMemberViewController.swift
//  AppointmentScheduler
//
//  Created by Scott Knutti on 1/14/16.
//  Copyright © 2016 Scott Knutti. All rights reserved.
//

import UIKit
import CoreData

protocol EditMemberViewControllerDelegate {
    func saveMember(var member: String)
}

class EditMemberViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memberNameTextfield: UITextField!
    @IBOutlet weak var memberPhoneTextfield: UITextField!
    @IBOutlet weak var memberEmailTextfield: UITextField!
    @IBOutlet weak var isInterviewerSwitch: UISwitch!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var doneButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButtonConstraint: NSLayoutConstraint!
    
    var member: Member!
    
    var delegate : EditMemberViewControllerDelegate?
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memberNameTextfield.delegate = self
        memberPhoneTextfield.delegate = self
        memberEmailTextfield.delegate = self
        
        if (member != nil) {
            titleLabel.text = "Edit Member"
            doneButton.setTitle("Update", forState: .Normal)
            populateForm()
        } else {
            titleLabel.text = "Add Member"
            doneButton.setTitle("Save", forState: .Normal)
        }
        
        memberNameTextfield.becomeFirstResponder()
        doneButtonConstraint.constant += 250
        view.addConstraint(doneButtonConstraint)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
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
        memberNameTextfield.text = member.memberName
        memberPhoneTextfield.text = member.memberPhone
        memberEmailTextfield.text = member.memberEmail
        isInterviewerSwitch.setOn(member.isInterviewer as Bool, animated: true)
    }
    
//    func textFieldDidBeginEditing(textField: UITextField) {
//        textField.selectedTextRange = textField.textRangeFromPosition(textField.beginningOfDocument, toPosition: textField.endOfDocument)
//    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveMember(sender: AnyObject) {
        dismissViewControllerAnimated(true) {
            let fetchRequest = NSFetchRequest(entityName: "Member")
            fetchRequest.predicate = NSPredicate(format: "memberName = %@", self.memberNameTextfield.text! as String)
            
            do {
                if let fetchResults = try self.sharedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                    if fetchResults.count != 0 {
                        let existingMember = fetchResults[0] as! Member
                        if (existingMember.memberName != self.member.memberName) {
                            self.member.delete()
                        }
                        existingMember.setValue(self.memberPhoneTextfield.text, forKey: "memberPhone")
                        existingMember.setValue(self.memberEmailTextfield.text, forKey: "memberEmail")
                        existingMember.setValue(self.isInterviewerSwitch.on ? 1 : 0, forKey: "isInterviewer")
                    } else {
                        RandomUserClient.sharedInstance.fetchRandomUser() { JSONResult, error in
                            dispatch_async(dispatch_get_main_queue()) {
                                if let results = JSONResult.objectForKey("results")![0] {
                                    let user = results["user"]!
                                    let profileImagePath = user!.objectForKey("picture")!["thumbnail"] as? String
                                    RandomUserClient.sharedInstance.downloadImage(profileImagePath!) { data, error in
                                        dispatch_async(dispatch_get_main_queue()) {
                                            let dictionary: [String : AnyObject] = ["memberName": self.memberNameTextfield.text! as String, "memberPhone": self.memberPhoneTextfield.text! as String, "memberEmail": self.memberEmailTextfield.text! as String, "isInterviewer": self.isInterviewerSwitch.on ? 1 : 0]
                                            let member = Member(dictionary: dictionary, context: self.sharedContext)
                                            member.profileImage = data
                                            CoreDataStackManager.sharedInstance().saveContext()
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
            } catch {
                print(error)
            }
            
        }
    }
    
    @IBAction func deleteMember(sender: AnyObject) {
        dismissViewControllerAnimated(true) {
            self.member.delete()
        }
    }
}


