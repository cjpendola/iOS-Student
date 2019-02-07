//
//  PostController.swift
//  WhyiOS2
//
//  Created by Jayden Garrick on 5/23/18.
//  Copyright © 2018 Jayden Garrick. All rights reserved.
//
import Foundation

class PostController {
    
    static let baseURL = URL(string: "https://whydidyouchooseios.firebaseio.com/")
    
    static func fetchPosts(completion: @escaping (([Post]?) -> Void)) {
        
        guard let url =  baseURL?.appendingPathComponent("reasons").appendingPathExtension("json")
        else {
                completion(nil)
                return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.httpBody = nil
        
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, error) in
            if let error = error {
                print("Error with posts: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                let postsDictionary = try jsonDecoder.decode([String:Post].self, from: data)
                let posts = postsDictionary.compactMap { $1 }
                completion(posts)
                return
            } catch let error {
                print("Error decoding posts: \(error.localizedDescription)")
                completion(nil)
                return
            }
        })
        dataTask.resume()
    }
    
    // POST
    static func postReason(name: String, reason: String, cohort: String, completion: @escaping ((Bool)->Void)) {
        
        guard let url =  baseURL?.appendingPathComponent("reasons").appendingPathExtension("json")
        else {
            completion(false)
            return
        }
        
        let post = Post(name: name, reason: reason, cohort: cohort)
        var postData: Data
        do {
            let jsonEncoder = JSONEncoder()
            postData = try jsonEncoder.encode(post)
        } catch  {
            print("Error encoding post into data: \(error.localizedDescription)")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error posting Post: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
            return
        }
        dataTask.resume()
        
        
    }
}
