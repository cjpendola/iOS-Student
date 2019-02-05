//
//  PostListViewController.swift
//  Post
//
//  Created by Carlos Pendola on 2/4/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//


import UIKit

class PostListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
   
    @IBOutlet weak var postTableVC: UITableView!
    
    //let postController = PostController()
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        getPosts()
    }
    
    func getPosts(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //PostController.fetchPosts {(posts) in
        PostController.fetchPosts {
            self.reloadTableView()
            //self.postController.posts = posts
        }
    }
    
    func setTableView(){
        self.postTableVC.estimatedRowHeight = 45
        self.postTableVC.rowHeight = UITableView.automaticDimension
        refreshControl.addTarget(self, action: #selector(refreshControlPulled), for: .valueChanged)
        self.postTableVC.refreshControl = refreshControl
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.postTableVC.reloadData()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    @IBAction func addPostButton(_ sender: UIBarButtonItem) {
        presentNewPostAlert()
    }
    
    func presentNewPostAlert() {
        let alertController = UIAlertController(title: "New Post", message: nil, preferredStyle: .alert)
        
        var usernameTextField: UITextField?
        var messageTextField: UITextField?
        
        alertController.addTextField { (usernameField) in
            usernameField.placeholder = "Display name"
            usernameTextField = usernameField
        }
        
        alertController.addTextField { (messageField) in
            messageField.placeholder = "What's up?"
            messageTextField = messageField
        }
        
        let postAction = UIAlertAction(title: "Post", style: .default) { (action) in
            guard let username = usernameTextField?.text, !username.isEmpty,
                let text = messageTextField?.text, !text.isEmpty else {
                    self.presentErrorAlert()
                    return
            }
            PostController.addPost(username: username, text: text, completion: {
                self.reloadTableView()
            })
        }
        alertController.addAction(postAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func presentErrorAlert() {
        
        let alertController = UIAlertController(title: "Uh oh!", message: "You may be missing information or have network connectivity issues. Please try again.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    @objc func refreshControlPulled() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        //PostController.fetchPosts {  (posts) in
        PostController.fetchPosts {
            //self.postController.posts = posts
            self.reloadTableView()
            DispatchQueue.main.async {
                self.postTableVC.refreshControl?.endRefreshing()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return PostController.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        let post = PostController.posts[indexPath.row]
        cell.textLabel?.text = post.text
        cell.detailTextLabel?.text = "\(indexPath.row) - \(post.username) - \(Date(timeIntervalSince1970: post.timestamp))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= PostController.posts.count - 1 {
            PostController.fetchPosts(reset: false, completion: {
                self.reloadTableView()
            })
        }
    }
    
    

}
