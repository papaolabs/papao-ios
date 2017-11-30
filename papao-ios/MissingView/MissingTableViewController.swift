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
    @IBOutlet weak var filterBarButtonItem: UIBarButtonItem!

    @IBOutlet weak var writeButton: UIButton!
    @IBOutlet weak var writeMissingButton: UIButton!
    @IBOutlet weak var writeMissingButtonView: UIView!
    let backgroundView = UIView()

    var postResponse: PostResponse?
    var filter = Filter.init(postTypes: [PostType.MISSING])
    let api = HttpHelper.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.tableFooterView = UIView()
        setPullToRefresh()
        
        // button customizing
        writeButton.setRadius(radius: writeButton.frame.width/2)
        writeMissingButton.setRadius(radius: writeMissingButton.frame.width/2)
        
        // backgroundView settings for floating buttons
        backgroundView.frame = view.frame
        backgroundView.backgroundColor = UIColor.init(white: 0, alpha: 0.7)
        backgroundView.isHidden = true
        backgroundView.alpha = 0
        view.addSubview(backgroundView)
        view.bringSubview(toFront: backgroundView)
        view.bringSubview(toFront: writeMissingButton)
        view.bringSubview(toFront: writeMissingButtonView)
        view.bringSubview(toFront: writeButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationSetting()
        
        writeMissingButtonView.isHidden = true
        writeMissingButtonView.alpha = 0
        writeMissingButtonView.frame.origin = CGPoint(x: writeMissingButtonView.frame.origin.x, y: view.frame.height - 74)
        
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

    fileprivate func clearPostData() {
        // index 초기화
        filter.index = "0"
        postResponse = nil
        tableView.reloadData()
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
            let writeMissingButtonPosition = CGPoint(x: writeMissingButtonView.frame.origin.x, y: self.writeButton.frame.origin.y - 16 - writeMissingButtonView.frame.height)
            
            self.backgroundView.isHidden = false
            self.writeMissingButtonView.isHidden = false
            UIView.animate(withDuration: 0.15, animations: {
                self.backgroundView.alpha = 1.0
                self.writeMissingButtonView.alpha = 1.0
                self.writeMissingButtonView.frame.origin = writeMissingButtonPosition
                self.writeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
            })
        } else {
            UIView.animate(withDuration: 0.15, animations: {
                self.backgroundView.alpha = 0
                self.writeMissingButtonView.alpha = 0
                self.writeMissingButtonView.frame.origin = CGPoint(x: self.writeMissingButtonView.frame.origin.x, y: self.writeButton.frame.origin.y)
                self.writeButton.transform = CGAffineTransform(rotationAngle: 0)
            }, completion: { (result) in
                self.backgroundView.isHidden = true
                self.writeMissingButtonView.isHidden = true
            })
        }
    }
    
    @IBAction func writeMissinButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "MissingSegue", sender: nil)
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FilterSegue" {
            if let viewController = segue.destination as? FilterViewController {
                // pass data to next viewController
                viewController.filter = filter
            }
        } else if segue.identifier == "MissingSegue" {
            if let viewController = segue.destination as? ReportImageUploadViewController,
                let user = AccountManager.sharedInstance.getLoggedUser() {
                viewController.post.postType = .MISSING
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

extension MissingTableViewController: UITableViewDelegate, UITableViewDataSource {
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
        return 140
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
