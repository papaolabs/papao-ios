//
//  MyPageViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 23..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import AccountKit
import Alamofire

class MyPageViewController: UITableViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var nicknameGeneratorButton: UIButton!

    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize UI
        profileImageView.setBorder(color: UIColor.init(named: "placeholderGray") ?? .gray, width: 3)
        profileImageView.setRadius(radius: profileImageView.frame.width/2)

        // remove extra empty cells
        tableView.tableFooterView = UIView()

        loadMyInfo()
    }
    
    func loadMyInfo() {
        // user id 필요한 내용
        accountKit.requestAccount { (account, error) in
            if let error = error {
                // 문제가 있거나 비회원일 때
                print(error)
            } else {
                if let accountId = account?.accountID {
                    let api = HttpHelper.init()
                    api.profile(userId: "9999", completion: { (result) in
                        do {
                            let user = try result.unwrap()
                            self.setProfile(user: user)
                        } catch {
                            print(error)
                        }
                    })
                }
            }
        }
    }
    
    func setProfile(user: User?) {
        if let user = user {
            phoneNumberLabel.text = user.phone
            nicknameLabel.text = user.nickName
            
            // set images
            if let url = user.profileUrl {
                Alamofire.request(url).responseData { response in
                    if let data = response.result.value {
                        let image = UIImage(data: data)
                        self.profileImageView.image = image
                    }
                }
            } else {
                self.profileImageView.image = UIImage.init(named: "dog_03")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}
