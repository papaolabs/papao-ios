//
//  MyPostViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 23..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class MyPostViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private var postResponse: PostResponse?
    var userId: String?
    var myPostOnlyfilter: Filter = Filter.init(postTypes: [.SYSTEM, .MISSING, .PROTECTING, .ROADREPORT])
    
    let api = HttpHelper.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userId = userId {
            myPostOnlyfilter.beginDate = nil
            myPostOnlyfilter.endDate = nil
            myPostOnlyfilter.userId = userId
            loadPostData()
        } else {
            // Todo: - 다시 로그인 처리
            print("로그인에 문제가 있습니다")
        }
    }

    fileprivate func loadPostData(index: String? = nil) {
        if let index = index {
            // 필터에 새 인덱스로 변경
            myPostOnlyfilter.index = index
            
            api.readPosts(filter: myPostOnlyfilter, completion: { (result) in
                do {
                    let newPostResponse = try result.unwrap()
                    if self.postResponse != nil {
                        // 기존에 post 목록 데이터가 있으면 elements에 추가
                        self.postResponse?.elements.append(contentsOf: newPostResponse.elements.flatMap{ $0 })
                    } else {
                        // 기존에 post 목록 데이터 없으면 (처음 요청인 경우)
                        self.postResponse = newPostResponse
                    }
                    self.tableView.reloadData()
                } catch {
                    print(error)
                }
            })
        } else {
            // 처음 api 요청
            api.readPosts(filter: myPostOnlyfilter, completion: { (result) in
                do {
                    let newPostResponse = try result.unwrap()
                    self.postResponse = newPostResponse
                    self.tableView.reloadData()
                } catch {
                    print(error)
                }
            })
        }
    }
}

extension MyPostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postResponse?.elements.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ReportTypePostTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postCellIdentifier",
                                                                              for: indexPath) as! ReportTypePostTableViewCell
        let row = indexPath.row;
        guard let post = postResponse?.elements[row] else {
            return cell
        }
        
        cell.setPost(post: post)
        
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 158
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let count = postResponse?.elements.count, indexPath.row == count-1 {
            //you might decide to load sooner than -1 I guess...
            //load more into data here
            loadPostData(index: "\(count)")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = self.postResponse?.elements[indexPath.row]
        guard let postDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostDetail") as? PostDetailViewController else {
            return
        }
        
        postDetailViewController.postId = row?.id
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
    }
}
