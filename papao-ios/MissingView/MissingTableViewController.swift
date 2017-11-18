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
    var posts: [Post] = []
    var filter = Filter.init(postTypes: [PostType.MISSING])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let api = HttpHelper.init()
        api.readPosts(filter: filter, completion: { (result) in
            do {
                self.posts = try result.unwrap()
                self.tableView.reloadData()
            } catch {
                print(error)
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MissingTableViewController: UITableViewDelegate, UITableViewDataSource {
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
        }
    }
}
