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
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        tableView.tableFooterView = backgroundView

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
                            self.user = user
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
            phoneNumberLabel.isHidden = false
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
            }
        }
    }
    
    private func presentLoginAlert() {
        let alert = UIAlertController(title: nil, message: "로그인 하시겠어요?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "네", style: .cancel) { (_) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(loginViewController, animated: true, completion: {
                // Todo: 로그인 처리
                self.loadMyInfo()
            })
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "아니오", style: .default) { (_) in
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: false)
    }
    
    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 16
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        if section == 0 && self.user == nil {
            // 로그인 안된 사용자 클릭 시
            presentLoginAlert()
        }
    }
}
