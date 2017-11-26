//
//  MissingTableViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 15..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire

class MissingTableViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    var postResponse: PostResponse?
    var filter = Filter.init(postTypes: [PostType.MISSING])
    let api = HttpHelper.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.backgroundView = emptyView
        setPullToRefresh()
        
        loadPostData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationSetting()
    }
    
    func setNavigationSetting() {
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.init(named: "textBlack") ?? .black
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.init(named: "textBlack") ?? .black]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barStyle = .default
    }

    func setPullToRefresh() {
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            let title = "당겨서 새로고침"
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl.addTarget(self,
                                     action: #selector(refreshOptions(sender:)),
                                     for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
    }
    
    @objc private func refreshOptions(sender: UIRefreshControl) {
        // index 초기화
        filter.index = "0"
        // 데이터 새로고침
        loadPostData()
        sender.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadPostData(index: String? = nil) {
        if let index = index {
            // 필터에 새 인덱스로 변경
            filter.index = index
            
            api.readPosts(filter: filter, completion: { (result) in
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
            api.readPosts(filter: filter, completion: { (result) in
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
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FilterSegue" {
            if let viewController = segue.destination as? FilterViewController {
                // pass data to next viewController
                viewController.filter = filter
            }
        }
    }
    
    @IBAction func unwindToPostViewController(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? FilterViewController, let filter = sourceViewController.filter {
            self.filter = filter
            
            // filter 적용 후 데이터 다시 로드
            loadPostData()
        }
    }
}

extension MissingTableViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = postResponse?.elements.count, count > 0 else {
            tableView.separatorStyle = .none
            return 0
        }
        tableView.separatorStyle = .singleLine
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PostTableViewCell = tableView.dequeueReusableCell(withIdentifier: "postCellIdentifier",
                                                                    for: indexPath) as! PostTableViewCell
        let row = indexPath.row;
        guard let post = postResponse?.elements[row] else {
            return cell
        }
        
        cell.setPost(post: post)
        
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let count = postResponse?.elements.count, indexPath.row == count - 1 {
            if let size = Int(filter.size) {
                let nextIndex = indexPath.row/size + 1
                loadPostData(index: "\(nextIndex)")
            } else {
                print("pagination에 문제가 있습니다")
            }
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
