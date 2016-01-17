//
//  CustomAppointmentCell.swift
//  AppointmentScheduler
//
//  Created by Scott Knutti on 1/16/16.
//  Copyright © 2016 Scott Knutti. All rights reserved.
//

import UIKit

class CustomAppointmentCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var dateDayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    @IBOutlet weak var interviewerLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var completedImage: UIImageView!
    
    override func layoutSubviews() {
        cardSetup()
        imageSetup()
    }
    
    func cardSetup() {
        cardView.alpha = 1
        cardView.layer.masksToBounds = false
        cardView.layer.cornerRadius = 1
        cardView.layer.shadowOffset = CGSizeMake(-0.2, 0.2)
        cardView.layer.shadowRadius = 1
        let path = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 10)
        cardView.layer.shadowPath = path.CGPath
        cardView.layer.shadowOpacity = 0.2
    }
    
    func imageSetup() {
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        profileImage.contentMode = .ScaleAspectFit
        profileImage.backgroundColor = UIColor.whiteColor()
    }
}