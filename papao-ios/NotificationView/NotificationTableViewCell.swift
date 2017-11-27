//
//  NotificationTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 22..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setPushLog(_ pushLog: PushLog) {
        contentLabel.text = pushLog.message
        dateLabel.text = pushLog.createdDate
        
        switch pushLog.type {
        case .alarm:
            typeImageView.image = UIImage.init(named: "iconBellNotice")
        case .post:
            typeImageView.image = UIImage.init(named: "iconBookmarkNotice")
        case .search:
            typeImageView.image = UIImage.init(named: "iconBookmarkNotice")
        }
    }
}
