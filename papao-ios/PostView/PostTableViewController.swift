//
//  ViewController.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 10. 14..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire

class PostTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let postDict: [String: String] = [
            "id": "1",
            "type": "01",
            "imageUrl": "http://www.animal.go.kr/files/shelter/2017/08/201710111610187.jpg",
            "kindUpCode": "417000",
            "kindCode": "50",
            "kindName": "프렌치 불독",
            "happenDate": "20171001",
            "happenPlace": "전라남도 나주시",
            "userId": "01",
            "userName": "ㅇㅇㅇ애견",
            "userAddress": "서울시 금천구",
            "userContact": "010-1234-5678",
            "weight": "4.0",
            "gender": "F",
            "state": "보호중",
            "neuter": "U",
            "feature": "프렌치불독",
            "introduction": ""
        ]
        let postDict2: [String: String] = [
            "id": "2",
            "desertionId": "445468201700459",
            "type": "01",
            "imageUrl": "http://www.animal.go.kr/files/shelter/2017/08/201710042010406.jpg",
            "kindUpCode": "417000",
            "kindCode": "128",
            "kindName": "푸들",
            "happenDate": "20171001",
            "happenPlace": "전라북도 익산시",
            "userId": "01",
            "userName": "익산유기동물보호소",
            "userAddress": "전라북도 익산시 함라면 신함1길 12-7 (함라면) ",
            "userContact": "063-831-7417",
            "weight": "3.0",
            "gender": "M",
            "state": "보호중",
            "neuter": "N",
            "feature": "상태 양호함",
            "introduction": ""
        ]
        let post = Post(postDict)
        let post2 = Post(postDict2)
        posts.append(post)
        posts.append(post2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PostTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postCellIdentifier",
                                                                  for: indexPath) as! PostTableViewCell
        let row = indexPath.row;
        let post = posts[row]
        
        cell.kindLabel.text = post.kindName
        cell.happenDateLabel.text = post.happenDate
        cell.happenPlaceLabel.text = post.happenPlace
        
        if let url = post.imageUrl {
            Alamofire.request(url).responseData { response in
                if let data = response.result.value {
                    let image = UIImage(data: data)
                    cell.postImageView.image = image
                }
            }
        }
        cell.favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.posts[indexPath.row]
        guard let postDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetail") as? PostDetailViewController else {
            return
        }

        postDetailViewController.post = row
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
}

