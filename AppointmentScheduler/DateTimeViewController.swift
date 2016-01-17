//
//  DateTimeViewController.swift
//  AppointmentScheduler
//
//  Created by Scott Knutti on 1/15/16.
//  Copyright © 2016 Scott Knutti. All rights reserved.
//

import Foundation
import UIKit

class DateTimeViewController: UIViewController {
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var delegate: EditAppointmentViewControllerDelegate?
    var appointment: Appointment!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func setDateTime(sender: AnyObject) {
        if (self.delegate != nil) {
            delegate?.addDateTime(datePicker.date)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}