//
//  ImageSearchTableViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 27..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit

class ImageSearchTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var emptyView: UIView!
    var postId: Int?
    var postResponse: PostResponse?
    let api = HttpHelper.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.isBeingPresented {
            // modal로 imageSearchTableView가 띄워졌을 때 (푸시 통해서 들어온 경우)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "닫기", style: UIBarButtonItemStyle.plain, target: self, action: #selector(close))
        }
        
        tableView.tableFooterView = UIView()
        setPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSearchResult()
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
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
        // 데이터 새로고침
        loadSearchResult()
        sender.endRefreshing()
    }
    
    func loadSearchResult() {
        if let postId = postId {
            api.search(postId: "\(postId)", completion: { (result) in
                do {
                    self.postResponse = try result.unwrap()
                    self.tableView.reloadData()
                } catch {
                    print(error)
                }
            })
        } else {
            print("postId가 잘못됐습니다")
        }
    }
}

extension ImageSearchTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = postResponse?.elements.count, count > 0 else {
            tableView.separatorStyle = .none
            tableView.backgroundView = emptyView
            return 0
        }
        tableView.separatorStyle = .singleLine
        tableView.backgroundView = nil
        return count
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
