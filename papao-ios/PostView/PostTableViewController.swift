//
//  ViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 14..
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

        let postString = "{\n" +
            "  \"id\": 257,\n" +
            "  \"type\": \"01\",\n" +
            "  \"imageUrls\": [\"http://www.animal.go.kr/files/shelter/2017/08/201709012009506.jpg\"],\n" +
            "  \"kindUpCode\": \"417000\",\n" +
            "  \"kindCode\": \"72\",\n" +
            "  \"kindName\": \"아메리칸 도고 아르젠티나\",\n" +
            "  \"happenDate\": \"20170901\",\n" +
            "  \"happenPlace\": \"경기도 남양주시\",\n" +
            "  \"userId\": \"01\",\n" +
            "  \"userName\": \"남양주동물보호협회\",\n" +
            "  \"userAddress\": \"경기도 남양주시 금곡로 44 (금곡동 성원빌딩) 1층\",\n" +
            "  \"userContact\": \"031-591-7270\",\n" +
            "  \"weight\": \"3.7\",\n" +
            "  \"gender\": \"M\",\n" +
            "  \"state\": \"종료(입양)\",\n" +
            "  \"neuter\": \"Y\",\n" +
            "  \"feature\": \"목줄 없고 온순함\",\n" +
            "  \"introduction\": \"\"\n" +
        "}"
        if let dict = postString.dictionaryFromJSON() {
            let post = Post(fromDict: dict)
            posts.append(post)
        }
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
        
        Alamofire.request(post.imageUrls[0]).responseData { response in
            if let data = response.result.value {
                let image = UIImage(data: data)
                cell.postImageView.image = image
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = self.posts[indexPath.row]
        guard let postDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetail") as? PostDetailViewController else {
            return
        }

        postDetailViewController.post = row
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
}

