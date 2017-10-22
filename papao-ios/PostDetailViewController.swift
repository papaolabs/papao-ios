//
//  PostDetailViewController.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 10. 17..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire

class PostDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    var post: Post? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - IBAction
    @objc func favoriteButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "즐겨찾기 되었습니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
        }
        alert.addAction(okAction)
        self.present(alert, animated: false)
        
        let button = sender as! UIButton
        button.tintColor = UIColor.gray
    }

    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        // Image, Button, Text 세가지
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1: // ImageCell, ButtonCell
            return 1
        case 2:
            if let thePost = post {
                return thePost.countOfTextInfo()
            }
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0:
            let cell: PostDetailImageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailImageCell",
                                                                        for: indexPath) as! PostDetailImageTableViewCell
            if let url = post?.imageUrl {
                Alamofire.request(url).responseData { response in
                    if let data = response.result.value {
                        let image = UIImage(data: data)
                        cell.postImageView.image = image
                        
                        // Comment: - Cell 높이를 이미지 비율에 맞게 재지정을 위한 트릭
                        UIView.setAnimationsEnabled(false)
                        tableView.beginUpdates()
                        tableView.endUpdates()
                        UIView.setAnimationsEnabled(true)
                    }
                }
            }
            // Todo: - 이미지 호출 후 이미지뷰 크기와 셀 높이를 재정의
            return cell
        case 1:
            let cell: PostDetailButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailButtonCell",
            for: indexPath) as! PostDetailButtonTableViewCell
            cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            return cell
        default:
            let cell: PostDetailTextTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailTextCell",
                                                                                    for: indexPath) as! PostDetailTextTableViewCell
            switch row {
            case 0:
                if let kindName = post?.kindName {
                    cell.titleLabel.text = "종류"
                    cell.contentLabel.text = kindName
                }
                break
            case 1:
                if let feature = post?.feature {
                    cell.titleLabel.text = "특징"
                    cell.contentLabel.text = feature
                }
            case 2:
                if let happenPlace = post?.happenPlace {
                    cell.titleLabel.text = "발생장소"
                    cell.contentLabel.text = happenPlace
                }
                break
            case 3:
                if let userName = post?.userName {
                    cell.titleLabel.text = "보호센터"
                    cell.contentLabel.text = userName
                }
                break
            case 4:
                if let userContact = post?.userContact {
                    cell.titleLabel.text = "연락처"
                    cell.contentLabel.text = userContact
                }
            default:
                break
            }
            
            // Todo: - 표시할 수 있는 모든 텍스트 정보를 동적으로 셀에 표시 필요
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            // Comment: - 스크린 사이즈 비율에 따른 이미지 높이로 이미지셀 높이 지정
            if let currentCell = tableView.cellForRow(at: indexPath) as? PostDetailImageTableViewCell {
                if let size = currentCell.postImageView.image?.size {
                    let aspectRatio = size.height/size.width
                    return aspectRatio * UIScreen.main.bounds.width
                }
            }
            return 44
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case 0:
            return 375
        default:
            return 44
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
