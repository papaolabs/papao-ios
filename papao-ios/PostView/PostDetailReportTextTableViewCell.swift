//
//  PostDetailReportTextTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 28..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class PostDetailReportTextTableViewCell: UITableViewCell {
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var weightLabel: UILabel!
    @IBOutlet var neuterLabel: UILabel!
    
    @IBOutlet var happenDateLabel: UILabel!
    @IBOutlet var happenPlaceLabel: UILabel!
    
    @IBOutlet var featureLabel: UILabel!
    @IBOutlet var userContactLabel: UILabel!
    
    // 실종, 제보 타이틀 변경용
    @IBOutlet weak var happenDateTitleLabel: UILabel!
    @IBOutlet weak var happenPlaceTitleLabel: UILabel!
    
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

        happenDateLabel.text = postDetail.happenDate
        happenPlaceLabel.text = postDetail.happenPlace
        featureLabel.text = postDetail.feature ?? ""
        userContactLabel.text = postDetail.managerContact ?? ""
        
        if (postDetail.postType == .MISSING) {
            happenDateTitleLabel.text = "실종날짜"
            happenPlaceTitleLabel.text = "실종장소"
        }
    }
}