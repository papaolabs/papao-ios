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
    @IBOutlet var emptyView: UIView!
    @IBOutlet weak var filterBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var writeButton: UIButton!
    @IBOutlet weak var writeRoadButton: UIButton!
    @IBOutlet weak var writeRoadButtonView: UIView!
    @IBOutlet weak var writeProtectionButton: UIButton!
    @IBOutlet weak var writeProtectionButtonView: UIView!
    let backgroundView = UIView()
    
    var postResponse: PostResponse?
    var filter = Filter.init(postTypes: [PostType.ROADREPORT, PostType.PROTECTING])
    let api = HttpHelper.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.tableFooterView = UIView()
        setPullToRefresh()
        
        // button customizing
        writeButton.setRadius(radius: writeButton.frame.width/2)
        writeRoadButton.setRadius(radius: writeRoadButton.frame.width/2)
        writeProtectionButton.setRadius(radius: writeProtectionButton.frame.width/2)
        
        // backgroundView settings for floating buttons
        backgroundView.frame = view.frame
        backgroundView.backgroundColor = UIColor.init(white: 0, alpha: 0.7)
        backgroundView.isHidden = true
        backgroundView.alpha = 0
        view.addSubview(backgroundView)
        view.bringSubview(toFront: backgroundView)
        view.bringSubview(toFront: writeRoadButtonView)
        view.bringSubview(toFront: writeProtectionButtonView)
        view.bringSubview(toFront: writeButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationSetting()
        
        writeRoadButtonView.isHidden = true
        writeRoadButtonView.alpha = 0
        writeRoadButtonView.frame.origin = CGPoint(x: writeRoadButtonView.frame.origin.x, y: view.frame.height - 74)
        writeProtectionButtonView.isHidden = true
        writeProtectionButtonView.alpha = 0
        writeProtectionButtonView.frame.origin = CGPoint(x: writeProtectionButtonView.frame.origin.x, y: view.frame.height - 74)
        
        // 화면 표시될 때 무조건 새로고침
        loadPostData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        writeButton.isSelected = false
        floatingButtonsActivate(activated: writeButton.isSelected)
    }

    func setNavigationSetting() {
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.ppTextBlack
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.ppTextBlack]
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
        // 데이터 새로고침
        clearPostData()
        loadPostData()
        sender.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPostData(index: String? = nil) {
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
    
    fileprivate func clearPostData() {
        // index 초기화
        filter.index = "0"
        postResponse = nil
        tableView.reloadData()
    }

    @IBAction func writeButtonPressed(_ sender: Any) {
        guard AccountManager.sharedInstance.getLoggedUser() != nil else {
            alert(message: "로그인이 필요한 화면입니다. 로그인 하시겠습니까?", confirmText: "네", cancel: true, completion: { (action) in
                self.goToLoginView()
            })
            return
        }
        
        writeButton.isSelected = !writeButton.isSelected
        floatingButtonsActivate(activated: writeButton.isSelected)
    }
    
    private func floatingButtonsActivate(activated: Bool) {
        if activated {
            let protectionButtonPosition = CGPoint(x: writeProtectionButtonView.frame.origin.x, y: self.writeButton.frame.origin.y - 16 - writeProtectionButton.frame.height)
            let roadButtonPosition = CGPoint(x: writeRoadButtonView.frame.origin.x, y: protectionButtonPosition.y - 8 - writeRoadButtonView.frame.height)
            
            self.backgroundView.isHidden = false
            self.writeRoadButtonView.isHidden = false
            self.writeProtectionButtonView.isHidden = false
            UIView.animate(withDuration: 0.15, animations: {
                self.backgroundView.alpha = 1.0
                self.writeRoadButtonView.alpha = 1.0
                self.writeProtectionButtonView.alpha = 1.0
                self.writeRoadButtonView.frame.origin = roadButtonPosition
                self.writeProtectionButtonView.frame.origin = protectionButtonPosition
                self.writeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
            })
        } else {
            UIView.animate(withDuration: 0.15, animations: {
                self.backgroundView.alpha = 0
                self.writeRoadButtonView.alpha = 0
                self.writeProtectionButtonView.alpha = 0
                self.writeRoadButtonView.frame.origin = CGPoint(x: self.writeRoadButtonView.frame.origin.x, y: self.writeButton.frame.origin.y)
                self.writeProtectionButtonView.frame.origin = CGPoint(x: self.writeProtectionButtonView.frame.origin.x, y: self.writeButton.frame.origin.y)
                self.writeButton.transform = CGAffineTransform(rotationAngle: 0)
            }, completion: { (result) in
                self.backgroundView.isHidden = true
                self.writeRoadButtonView.isHidden = true
                self.writeProtectionButtonView.isHidden = true
            })
        }
    }
    
    @IBAction func roadReportButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "RoadReportSegue", sender: nil)
    }
    
    @IBAction func protectionReportButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "ProtectionReportSegue", sender: nil)
    }
    
    fileprivate func alert(message: String, confirmText: String, cancel: Bool = false, completion: @escaping ((_ action: UIAlertAction) -> Void)) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        if cancel {
            let cancelAction = UIAlertAction(title: "아니오", style: .default)
            alert.addAction(cancelAction)
        }
        let okAction = UIAlertAction(title: confirmText, style: .cancel, handler: completion)
        alert.addAction(okAction)
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
        } else if segue.identifier == "ProtectionReportSegue" {
            if let viewController = segue.destination as? ReportImageUploadViewController,
                let user = AccountManager.sharedInstance.getLoggedUser() {
                viewController.post.postType = .PROTECTING
                viewController.post.uid = user.id
            } else {
                alert(message: "로그인이 필요한 화면입니다. 로그인 하시겠습니까?", confirmText: "네", cancel: true, completion: { (action) in
                    self.goToLoginView()
                })
            }
        } else if segue.identifier == "RoadReportSegue" {
            if let viewController = segue.destination as? QuickReportUploadViewController,
                let user = AccountManager.sharedInstance.getLoggedUser() {
                viewController.post.postType = .ROADREPORT
                viewController.post.uid = user.id
            } else {
                alert(message: "로그인이 필요한 화면입니다. 로그인 하시겠습니까?", confirmText: "네", cancel: true, completion: { (action) in
                    self.goToLoginView()
                })
            }
        }
    }
    
    @IBAction func unwindToPostViewController(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? FilterViewController, let filter = sourceViewController.filter {
            // 새 필터 적용
            self.filter = filter
            
            // 데이터 초기화
            clearPostData()
            
            // BarButtonItem 틴트 변경
            filterBarButtonItem.tintColor = UIColor.ppWarmPink
            
            // filter 적용 후 데이터 다시 로드
            loadPostData()
        }
    }
}

extension ReportTableViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView DataSource
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
        // 현재 로딩 된 포스트의 총 개수가 포스트 총 개수보다 작고, 마지막 직전 셀이 노출 될 예정인 경우 다음 페이지 로딩
        if let postResponse = postResponse,
            postResponse.totalElements > postResponse.elements.count,
            indexPath.row == postResponse.elements.count - 1 {
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
