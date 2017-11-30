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
        if let startDay = postDetail.noticeBeginDate?.toDate(format: "yyyyMMdd")?.toString(format: "yyyy년 MM월 dd일"),
            let endDay = postDetail.noticeEndDate?.toDate(format: "yyyyMMdd")?.toString(format: "yyyy년 MM월 dd일") {
            desertionDateLabel.text = "\(startDay) - \(endDay)"
        } else {
            
        }
        happenDateLabel.text = postDetail.happenDate.toDate(format: "yyyyMMdd")?.toString(format: "yyyy년 MM월 dd일")
        happenPlaceLabel.text = postDetail.happenPlace
        featureLabel.text = postDetail.feature ?? ""
        userContactLabel.text = "\(postDetail.managerName ?? "") (\(postDetail.managerContact ?? ""))"
    }
}

