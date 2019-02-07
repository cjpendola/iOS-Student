//
//  PostsTableViewController.swift
//  whyiOS
//
//  Created by Carlos Pendola on 2/6/19.
//  Copyright © 2019 Carlos Pendola. All rights reserved.
//

import UIKit

class PostsTableViewController: UITableViewController {
    
    // Source of truth
    var fetchedPosts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPosts()
    }
    
    // MARK: - Actions
    @IBAction func refreshButtonTapped(_ sender: Any) {
        getPosts()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        presentAddReasonAlert()
    }
    
    func getPosts() {
        PostController.fetchPosts { (posts) in
            guard let posts = posts else { return }
            self.fetchedPosts = posts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: "reasonCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell()}
        
        let post = fetchedPosts[indexPath.row]
        
        cell.nameLabel.text = post.name
        cell.cohortLabel.text = post.cohort
        cell.reasonLabel.text = post.reason
        
        return cell
    }
    
    
    
}

// MARK: - Alerts
extension PostsTableViewController {
    
    func presentAddReasonAlert() {
       
        var mynameTextField: UITextField?
        var myreasonTextField: UITextField?
        var mycohortTextField: UITextField?
        
        let reasonAlert = UIAlertController(title: "Why did you choose to learn iOS?", message: nil, preferredStyle: .alert)
        
        reasonAlert.addTextField { (nameTextField) in
            nameTextField.placeholder = "Enter your name"
            mynameTextField = nameTextField
        }
        
        reasonAlert.addTextField { (cohortTextField) in
            cohortTextField.placeholder = "Enter your cohort name"
            mycohortTextField = cohortTextField
        }
        
        reasonAlert.addTextField { (reasonTextField) in
            reasonTextField.placeholder = "Why are you iOS?"
            myreasonTextField = reasonTextField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addReasonAction = UIAlertAction(title: "Add Reason", style: .default) { (_) in
            
            guard let name = mynameTextField?.text,
                let cohort = mycohortTextField?.text,
                let reason = myreasonTextField?.text else { return }
            
            PostController.postReason(name: name, reason: reason, cohort: cohort, completion: { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.getPosts()
                    }
                } else {
                    print("Something went wrong :( ")
                }
            })
        }
        reasonAlert.addAction(addReasonAction)
        reasonAlert.addAction(cancelAction)
       
        present(reasonAlert, animated: true)
    }
    
}
