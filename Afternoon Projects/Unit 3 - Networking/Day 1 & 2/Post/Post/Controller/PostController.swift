//
//  PostController.swift
//  Post
//
//  Created by Carlos Pendola on 2/4/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

class PostController{
    private static let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    static var posts: [Post] = []
    
    //static func fetchPosts(completion: @escaping(( _ posts : [Post] ) -> Void))
    static func fetchPosts(reset: Bool = true, completion: @escaping () -> Void) {
        guard let unwrappedURL = baseURL else { fatalError("URL optional is having issues") }

        let queryEndInterval = reset ? Date().timeIntervalSince1970 : posts.last?.queryTimestamp ?? Date().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy": "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
        ]
        let queryItems = urlParameters.compactMap( { URLQueryItem(name: $0.key, value: $0.value) } )
        
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else { completion(); return }
        let getterEndpoint = url.appendingPathExtension("json")
        
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        //handle my data and errors accordingly
        let dataTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, error) in
            if let error = error {
                NSLog("\(error) : \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let data = data else { NSLog("No data returned"); completion();  return }
            do {
                let jsonDecoder = JSONDecoder()
                let postsDictionary = try jsonDecoder.decode([String:Post].self, from: data)
                let posts: [Post] = postsDictionary.compactMap( { $0.value })
                let sortedPosts = posts.sorted(by: { $0.timestamp > $1.timestamp })
                if reset {
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
            } catch let error {
                NSLog("ERROR decoding: \(error.localizedDescription)")
                completion()
            }
        })
        dataTask.resume()
        
    }
    
    
    static func addPost(username: String, text: String, completion: @escaping() -> Void) {
        guard let unwrappedURL = baseURL else { fatalError("URL optional is having issues") }
        
        let post = Post(username: username, text: text)
        var postData: Data
        do {
            let encoder = JSONEncoder()
            postData = try encoder.encode(post)
        } catch let error {
            NSLog("Error encoding data \(error) : \(error.localizedDescription)")
            completion()
            return
        }
    
        let postEndpoint = unwrappedURL.appendingPathExtension("json")
        var request = URLRequest(url: postEndpoint)
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error { completion(); NSLog(error.localizedDescription) }
            guard let data = data,
            let _ = String(data: data, encoding: .utf8) //responseDataString
            else {
                NSLog("Error")
                completion()
                return
            }
            self.fetchPosts {
                completion()
            }
        }
        dataTask.resume()
    }

    
}
