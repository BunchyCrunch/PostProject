//
//  PostController.swift
//  Post
//
//  Created by Josh Sparks on 9/30/19.
//  Copyright © 2019 DevMtnStudent. All rights reserved.
//

import Foundation

class PostController {
    
    let baseURL = URL(string: "http://devmtn-posts.firebaseio.com/posts")
    
    var posts: [Post] = []
    
    func fetchPosts(reset: Bool = true, completion: @escaping() -> Void) {
        
        let queryEndInterval = reset ? Date().timeIntervalSince1970: posts.last?.queryTimeStamp ?? Date().timeIntervalSince1970
        
        let urlParameters = [
            "orderBy" : "\"timestamp\"",
            "endAt": "\(queryEndInterval)",
            "limitToLast": "15",
        ]
        guard let unwrappedURL = self.baseURL else { return }
        
        let queryItems = urlParameters.compactMap({ URLQueryItem(name: $0.key, value: $0.value) })
        var urlComponents = URLComponents(url: unwrappedURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems
        guard let url = urlComponents?.url else { return }
        
        let getterEndpoint = url.appendingPathExtension("json")
        var request = URLRequest(url: getterEndpoint)
        request.httpBody = nil
        request.httpMethod = "GET"
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                print("Error decoding the Data! \(error.localizedDescription)")
                completion()
                return
            }
            guard let data = data else { return }
            let jsonDecoder = JSONDecoder()
            
            do {
                let postsDictionary = try jsonDecoder.decode([String:Post].self, from: data)
                var sortedPosts = postsDictionary.compactMap({$0.value})
                sortedPosts.sort(by: {$0.timestamp > $1.timestamp})
                if reset == true {
                    self.posts = sortedPosts
                } else {
                    self.posts.append(contentsOf: sortedPosts)
                }
                completion()
            } catch {
                completion()
                return
            }
        }
        dataTask.resume()
    }
    
    func addNewPostWith(username: String, text: String, completion: @escaping() -> Void) {
        let post = Post(username: username, text: text)
        var postData: Data
        
        do {
            let jsonEncoder = JSONEncoder()
            postData = try jsonEncoder.encode(post)
        } catch {
            print("Error encoding the data \(error.localizedDescription)")
            completion()
            return
        }
        guard let unwrappedURL = baseURL else { completion(); return }
        let postEndpoint = unwrappedURL.appendingPathExtension("json")
        var urlRequest = URLRequest(url: postEndpoint)
        urlRequest.httpMethod = "Post"
        urlRequest.httpBody = postData
        
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                print("There was an error performing the dataTask \(error.localizedDescription)")
                completion()
                return
            }
            guard let data = data else { return }
            let returnedData = String(data: data, encoding: .utf8)
            print(returnedData!)
            self.fetchPosts {
                completion()
            }
        }
        dataTask.resume()
    }
    
    
}// end of class
