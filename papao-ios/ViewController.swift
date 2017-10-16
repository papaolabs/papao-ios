//
//  ViewController.swift
//  papao-ios
//
//  Created by 1002719 on 2017. 10. 14..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
            "userContracts": "010-1234-5678",
            "weight": "4.0",
            "gender": "F",
            "state": "보호중",
            "neuter": "U",
            "feature": "프렌치불독",
            "introduction": ""
        ]
        let post = Post(postDict)
        posts.append(post)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "postCellIdentifier",
                                                                  for: indexPath)
        let row = indexPath.row;
        let post = posts[row]
        
        cell.textLabel?.text = post.kindName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

