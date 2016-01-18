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
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
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
        
        navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel:"), animated: true)
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
        profileImage!.image = member.profileImage
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveMember(sender: AnyObject) {
        let fetchRequest = NSFetchRequest(entityName: "Member")
        fetchRequest.predicate = NSPredicate(format: "memberName = %@", self.memberNameTextfield.text! as String)
        
        do {
            if let fetchResults = try self.sharedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                if fetchResults.count != 0 {
                    print(self.memberNameTextfield.text?.characters.count)
                    print(self.memberNameTextfield.text?.characters.count < 1)
                    if (self.memberNameTextfield.text?.characters.count < 1) {
                        let alert = UIAlertController(title: "Error", message: "Cannot save a member without a name.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        let existingMember = fetchResults[0] as! Member
                        if (existingMember.memberName != self.member.memberName) {
                            self.member.delete()
                        }
                        existingMember.setValue(self.memberPhoneTextfield.text, forKey: "memberPhone")
                        existingMember.setValue(self.memberEmailTextfield.text, forKey: "memberEmail")
                        existingMember.setValue(self.isInterviewerSwitch.on ? 1 : 0, forKey: "isInterviewer")
                        
                        dismissViewControllerAnimated(true, completion: nil)
                    }
                } else {
                    if (self.memberNameTextfield.text?.characters.count < 1) {
                        let alert = UIAlertController(title: "Error", message: "Cannot save a member without a name.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        if member == nil {
                            let dictionary: [String : AnyObject] = ["memberName": self.memberNameTextfield.text! as String, "memberPhone": self.memberPhoneTextfield.text! as String, "memberEmail": self.memberEmailTextfield.text! as String, "isInterviewer": self.isInterviewerSwitch.on ? 1 : 0]
                            member = Member(dictionary: dictionary, context: sharedContext)
                        } else {
                            member.setValue(self.memberPhoneTextfield.text, forKey: "memberPhone")
                            member.setValue(self.memberEmailTextfield.text, forKey: "memberEmail")
                            member.setValue(self.isInterviewerSwitch.on ? 1 : 0, forKey: "isInterviewer")
                        }
                        
                        dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func deleteMember(sender: AnyObject) {
        dismissViewControllerAnimated(true) {
            self.member.delete()
        }
    }
    
    @IBAction func getProfileImage(sender: AnyObject) {
        let status = Reach().connectionStatus()
        switch status {
        case .Offline, .Unknown:
            let alert = UIAlertController(title: "Network Failure", message: "No network connectivity", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        default:
            activityIndicator.startAnimating()
            RandomUserClient.sharedInstance.fetchRandomUser() { JSONResult, error in
                dispatch_async(dispatch_get_main_queue()) {
                    if let results = JSONResult.objectForKey("results")![0] {
                        let user = results["user"]!
                        let profileImagePath = user!.objectForKey("picture")!["thumbnail"] as? String
                        RandomUserClient.sharedInstance.downloadImage(profileImagePath!) { data, error in
                            dispatch_async(dispatch_get_main_queue()) {
                                if self.member == nil {
                                    let dictionary: [String : AnyObject] = ["memberName": self.memberNameTextfield.text! as String, "memberPhone": self.memberPhoneTextfield.text! as String, "memberEmail": self.memberEmailTextfield.text! as String, "isInterviewer": self.isInterviewerSwitch.on ? 1 : 0]
                                    self.member = Member(dictionary: dictionary, context: self.sharedContext)
                                }
                                let pieces = profileImagePath!.componentsSeparatedByString("/")
                                self.member.profileImagePath = pieces[pieces.count-1]
                                self.member.profileImage = UIImage(data: data)
                                self.profileImage.image = UIImage(data: data)
                                self.activityIndicator.stopAnimating()
                            }
                        }
                    }
                }
            }
        }
    }
}


