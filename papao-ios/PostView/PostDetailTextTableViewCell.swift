//
//  PostDetailLabelTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 19..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class PostDetailTextTableViewCell: UITableViewCell {
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var neuterLabel: UILabel!
    
    @IBOutlet var desertionNumberLabel: UILabel!
    @IBOutlet var desertionDateLabel: UILabel!
    
    @IBOutlet var happenDateLabel: UILabel!
    @IBOutlet var happenPlaceLabel: UILabel!
    
    @IBOutlet var featureLabel: UILabel!
    @IBOutlet var userContactLabel: UILabel!
    
    func setPostDetail(_ postDetail: PostDetail?) {
        guard let postDetail = postDetail else {
            return
        }
        
        genderLabel.text = postDetail.genderType.description
        ageLabel.text = postDetail.age?.description
        
        if let weight = postDetail.weight {
            weightLabel.text = "\(weight) kg"
        } else {
            weightLabel.text = "모름"
        }
        
        neuterLabel.text = postDetail.neuterType.description
        
        desertionNumberLabel.text = postDetail.desertionId ?? ""
        if let startDay = postDetail.noticeBeginDate, let endDay = postDetail.noticeEndDate {
            desertionDateLabel.text = "\(startDay)-\(endDay)"
        } else {
            
        }
        happenDateLabel.text = postDetail.happenDate
        happenPlaceLabel.text = postDetail.happenPlace
        featureLabel.text = postDetail.feature ?? ""
        userContactLabel.text = "\(postDetail.shelterName ?? postDetail.managerName ?? "") (\(postDetail.managerContact ?? ""))"
    }
}

