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
import SDWebImage

class MyPageViewController: UITableViewController {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var nicknameGeneratorButton: UIButton!

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationSetting()
        
        loadMyInfo()
    }
    
    func setNavigationSetting() {
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.init(named: "textBlack") ?? .black
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.init(named: "textBlack") ?? .black]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .default
    }

    
    func loadMyInfo() {
        user = AccountManager.sharedInstance.getLoggedUser()
        setProfile(user: user)
    }
    
    func setProfile(user: User?) {
        if let user = user {
            phoneNumberLabel.isHidden = false
            phoneNumberLabel.text = user.phone
            nicknameLabel.text = user.nickname
            
            // set images
            if let url = user.profileUrl {
                let placeholderImage = UIImage(named: "placeholder")!
                profileImageView.sd_setImage(with: URL(string: url)!, placeholderImage: placeholderImage)
            }
        } else {
            phoneNumberLabel.isHidden = true
            nicknameLabel.text = "로그인 해주세요"
            profileImageView.image = UIImage.init(named: "dog_03")
        }
    }
    
    private func presentLoginAlert() {
        let alert = UIAlertController(title: nil, message: "로그인 하시겠어요?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "네", style: .cancel) { (_) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
            self.present(loginViewController, animated: true, completion: nil)
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "아니오", style: .default) { (_) in
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: false)
    }
    
    private func presentLogoutAlert() {
        let alert = UIAlertController(title: nil, message: "로그아웃 하시겠어요?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "네", style: .default) { (_) in
            AccountManager.sharedInstance.logout()
            self.user = nil
            self.loadMyInfo()
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "아니오", style: .cancel) { (_) in
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: false)
    }
    
    func goToMyPostView() {
        guard let myPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyPostView") as? MyPostViewController else {
            return
        }
        
        myPostViewController.userId = user?.id
        self.navigationController?.pushViewController(myPostViewController, animated: true)
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
        if (section == 0 || section == 1) && self.user == nil {
            // 로그인 안된 사용자 클릭 시
            presentLoginAlert()
            return
        }
        
        switch section {
        case 0:
            presentLogoutAlert()
        case 1:
            goToMyPostView()
        default: break
        }
    }
}
