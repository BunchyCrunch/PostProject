//
//  PostListViewController.swift
//  Post
//
//  Created by Josh Sparks on 9/30/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import UIKit

class PostListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Outlets
    
    @IBOutlet weak var postListTableView: UITableView!
        
    let postController = PostController()
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postListTableView.delegate = self
        postListTableView.dataSource = self
        postController.fetchPosts {
        }
        postListTableView.estimatedRowHeight = 45
        postListTableView.rowHeight = UITableView.automaticDimension
        postListTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        postController.fetchPosts {
            self.reloadTableView()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = postController.posts[indexPath.row]
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = post.username
        return cell
    }
    @objc func refreshControlPulled() {
        postController.fetchPosts {
            self.reloadTableView()
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
        
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.postListTableView.reloadData()
        }
    }
    
    func presentNewPostAlert() {
        let newPostAlertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        
        var username = UITextField()
        newPostAlertController.addTextField { (usernameTextField) in
            usernameTextField.placeholder = "Enter username"
            username = usernameTextField
        }
        var message = UITextField()
        newPostAlertController.addTextField { (messageTextField) in
            messageTextField.placeholder = "Enter message"
            message = messageTextField
        }
        
        let postAlertAction = UIAlertAction(title: "Post", style: .default) { (postAlertAction) in
            guard let name = username.text, !name.isEmpty,
                let text = message.text, !text.isEmpty else {
                    return
            }
            self.postController.addNewPostWith(username: name, text: text, completion: {
                self.reloadTableView()
        })
    }
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        newPostAlertController.addAction(postAlertAction)
        newPostAlertController.addAction(cancelAlertAction)
        
        self.present(newPostAlertController, animated: true, completion: nil)
    }
    
    //MARK: Actions
    @IBAction func addButtonTapped(_ sender: Any) {
        presentNewPostAlert()
    }
} // end of class

extension PostListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= postController.posts.count - 1 {
            postController.fetchPosts(reset: false) {
                self.reloadTableView()
            }
        }
    }
}
