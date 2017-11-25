//
//  ReportListViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 10. 22..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire

class ReportTableViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var postResponse: PostResponse?
    var filter = Filter.init(postTypes: [PostType.ROADREPORT, PostType.PROTECTING])
    let api = HttpHelper.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setPullToRefresh()
        
        loadPostData()
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
    
    @IBAction func quickReportButtonPressed(_ sender: Any) {
        guard AccountManager.sharedInstance.getLoggedUser() != nil else {
            alert(message: "로그인이 필요한 화면입니다. 로그인 하시겠습니까?", confirmText: "네", cancel: true, completion: { (action) in
                self.goToLoginView()
            })
            return
        }
        
        performSegue(withIdentifier: "quickReportSegue", sender: nil)
    }
    
    @IBAction func normalReportButtonPressed(_ sender: Any) {
        guard AccountManager.sharedInstance.getLoggedUser() != nil else {
            alert(message: "로그인이 필요한 화면입니다. 로그인 하시겠습니까?", confirmText: "네", cancel: true, completion: { (action) in
                self.goToLoginView()
            })
            return
        }

        performSegue(withIdentifier: "normalReportSegue", sender: nil)
    }

    fileprivate func alert(message: String, confirmText: String, cancel: Bool = false, completion: @escaping ((_ action: UIAlertAction) -> Void)) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: confirmText, style: .cancel, handler: completion)
        alert.addAction(okAction)
        if cancel {
            let cancelAction = UIAlertAction(title: "아니오", style: .default)
            alert.addAction(cancelAction)
        }
        self.present(alert, animated: false)
    }
    
    fileprivate func goToLoginView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        present(loginViewController, animated: true, completion: nil)
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

extension ReportTableViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postResponse?.totalElements ?? 0
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
        return 158
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
