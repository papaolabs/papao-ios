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
            "  \"id\": 1912741,\n" +
            "  \"stateType\": \"PROCESS\",\n" +
            "  \"genderType\": \"M\",\n" +
            "  \"imageUrls\": [\n" +
            "    {\n" +
            "      \"key\": 1920705,\n" +
            "      \"url\": \"http://www.animal.go.kr/files/shelter/2017/11/201711111011903.jpg\"\n" +
            "    }\n" +
            "  ],\n" +
            "  \"happenDate\": \"20171111\",\n" +
            "  \"happenPlace\": \"경기도 안양시\",\n" +
            "  \"kindName\": \"포메라니안\",\n" +
            "  \"hitCount\": 0,\n" +
            "  \"commentCount\": 0,\n" +
            "  \"createdDate\": \"2017-11-11 10:20:01\",\n" +
            "  \"updatedDate\": \"2017-11-11 18:30:00\"\n" +
        "}"
        if let dict = postString.dictionaryFromJSON(), let post = Post(json: dict) {
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
        
        cell.setPost(post: post)
        cell.kindLabel.text = post.kindName
        cell.happenDateLabel.text = post.happenDate
        cell.happenPlaceLabel.text = post.happenPlace
        
        if post.imageUrls.count > 0 {
            if let url = post.imageUrls[0]["url"] as? String {
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

        postDetailViewController.postId = row.id
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
}

