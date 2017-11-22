//
//  BookmarkViewController.swift
//  papao-ios
//
//  Created by closer27 on 2017. 11. 22..
//  Copyright © 2017년 papaolabs. All rights reserved.
//

import UIKit
import Alamofire

class BookmarkViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var postResponse: PostResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

extension BookmarkViewController: UITableViewDelegate, UITableViewDataSource {
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
