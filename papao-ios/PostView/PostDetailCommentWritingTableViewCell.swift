//
//  PostDetailCommentWritingTableViewCell.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 19..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class PostDetailCommentWritingTableViewCell: UITableViewCell {
    @IBOutlet weak var innerContentView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    var onSendPressed : ((String?) -> Void)?
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        innerContentView.roundCorners([.bottomLeft, .bottomRight], radius: 4.0)
    }
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        if let onSendPressed = self.onSendPressed {
            onSendPressed(self.textField.text)
            // Todo: api 성공 했을 때만 text 초기화
            textField.text = ""
        }
    }
}
