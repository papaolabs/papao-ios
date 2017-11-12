//
//  PostDetailViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 17..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire

enum PostDetailSection: Int {
    case image = 0
    case menu
    case description
    case comment
    
    static var count: Int { return PostDetailSection.comment.hashValue + 1}
}

class PostDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var speciesLabel: PPOBadge!
    @IBOutlet weak var breedLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var hitCountLabel: UILabel!
    
    var postId: Int?
    private var postDetail: PostDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speciesLabel.setStyle(type: .medium)
        
        let footer = UIView.init(frame: CGRect.zero)
        tableView.tableFooterView = footer
        
        if let postId = postId {
            getPostDetail(postId: postId)
        }
    }
    
    func getPostDetail(postId: Int) {
        let postDetailString = "{\n" +
            "  \"id\": 1912741,\n" +
            "  \"desertionId\": \"441383201700553\",\n" +
            "  \"stateType\": \"PROCESS\",\n" +
            "  \"postType\": \"SYSTEM\",\n" +
            "  \"genderType\": \"M\",\n" +
            "  \"neuterType\": \"N\",\n" +
            "  \"imageUrls\": [\n" +
            "    {\n" +
            "      \"key\": 1920886,\n" +
            "      \"url\": \"http://www.animal.go.kr/files/shelter/2017/11/201711111011903.jpg\"\n" +
            "    }\n" +
            "  ],\n" +
            "  \"feature\": \"포메믹스, 귀끝이 흑색, 미용됨, 기본훈련됨\",\n" +
            "  \"shelterName\": \"한국야생동물보호협회\",\n" +
            "  \"managerName\": \"안양시\",\n" +
            "  \"managerContact\": \"031-8045-2605\",\n" +
            "  \"happenDate\": \"20171111\",\n" +
            "  \"happenPlace\": \"삼천리자전거맞은편\",\n" +
            "  \"upKindName\": \"개\",\n" +
            "  \"kindName\": \"포메라니안\",\n" +
            "  \"sidoName\": \"경기도\",\n" +
            "  \"gunguName\": \"안양시\",\n" +
            "  \"age\": 2016,\n" +
            "  \"weight\": 3,\n" +
            "  \"hitCount\": 1,\n" +
            "  \"createdDate\": \"2017-11-11 10:20:01\",\n" +
            "  \"updatedDate\": \"2017-11-11 19:20:00\"\n" +
        "}"
        if let dict = postDetailString.dictionaryFromJSON(), let postDetail = PostDetail(json: dict) {
            self.postDetail = postDetail
            
            speciesLabel.setTitle(postDetail.upKindName, for: .normal)
            breedLabel.text = postDetail.kindName
            commentLabel.text = "\(postDetail.commentCount ?? 0)"
            hitCountLabel.text = "\(postDetail.hitCount ?? 0)"
        }
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
        // Image, Menu, Description, Comment 세가지
        return PostDetailSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case PostDetailSection.image.hashValue:
            let cell: PostDetailImageTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailImageCell",
                                                                        for: indexPath) as! PostDetailImageTableViewCell
            if let urlDict: [String: Any] = postDetail?.imageUrls[0], let url = urlDict["url"] as? String {
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
        case PostDetailSection.menu.hashValue:
            let cell: PostDetailButtonTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailButtonCell",
            for: indexPath) as! PostDetailButtonTableViewCell
            cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed(_:)), for: UIControlEvents.touchUpInside)
            return cell
        case PostDetailSection.description.hashValue:
            let cell: PostDetailTextTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailTextCell",
                                                                                    for: indexPath) as! PostDetailTextTableViewCell
            cell.setPostDetail(postDetail)
            return cell
        case PostDetailSection.comment.hashValue:
            let cell: PostDetailCommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postDetailCommentCell",
                                                                              for: indexPath) as! PostDetailCommentTableViewCell
            cell.setPostDetail(postDetail)
            return cell
        default:
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case PostDetailSection.image.rawValue:
            // Comment: - 스크린 사이즈 비율에 따른 이미지 높이로 이미지셀 높이 지정
            if let currentCell = tableView.cellForRow(at: indexPath) as? PostDetailImageTableViewCell {
                if let size = currentCell.postImageView.image?.size {
                    let aspectRatio = size.height/size.width
                    return aspectRatio * UIScreen.main.bounds.width
                }
            }
            return 40
        case PostDetailSection.description.rawValue:
            return 244
        default:
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        switch section {
        case PostDetailSection.image.rawValue:
            return 421
        case PostDetailSection.description.rawValue:
            return 244
        default:
            return 40
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
