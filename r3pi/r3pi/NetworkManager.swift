//
//  NetworkManager.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 05/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import UIKit

typealias SuccessCompletionBlockType = ((_ success: Bool, _ error: Error?) -> ())

typealias FetchCompletionBlockType = ((_ results: [Any]?, _ error: Error?) -> ())

typealias SendCompletionBlockType = ((_ results: Any?, _ error: Error?) -> ())

typealias PaginatedFetchCompletionBlockType = ((_ fetchCount: Int, _ error: Error?) -> ())

typealias CustomHeader = (() -> (key: String, value: String))

typealias JSONObject = [String: Any]

class NetworkManager: NSObject {
    
    static let sharedInstance = NetworkManager()
    
    // MARK: - Network Indicator
    
    private var networkIndicatorCount = 0
    
    func showNetworkIndicator() {
        
        networkIndicatorCount += 1
        
        if networkIndicatorCount == 1 {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    func hideNetworkIndicator() {
        
        networkIndicatorCount -= 1
        
        if networkIndicatorCount <= 0 {
            
            networkIndicatorCount = 0
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    // MARK: - Base network request
    
    internal lazy var defaultSession = URLSession(configuration: URLSessionConfiguration.default)
    
    private func send(request urlRequest: URLRequest, customHeader: CustomHeader? = nil, completion: SendCompletionBlockType?) {
        
        showNetworkIndicator()
        
        #if DEBUG
            var headers: String = ""
            if urlRequest.allHTTPHeaderFields == nil {
                
                headers = "EMPTY HEADERS"
            }
            else {
                
                for (key, value) in urlRequest.allHTTPHeaderFields! {
                    
                    if headers.characters.count > 0 {
                        
                        headers += "\n"
                    }
                    
                    headers += "\(key) : \(value)"
                }
            }
            
            print("\(urlRequest.httpMethod!) \(urlRequest.url!) headers:\n\(headers)")
        #endif
        
        let dataTask = defaultSession.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            #if DEBUG
                let httpCode = response != nil ? (response as! HTTPURLResponse).statusCode : -666
                let dataString = data != nil ? String(data: data!, encoding: .utf8) : "EMPTY"
                print("\(urlRequest.httpMethod!) \(urlRequest.url!) -> \(httpCode)\n\(dataString ?? "EMPTY"), error: \(String(describing: error))")
            #endif
            
            DispatchQueue.main.async {
                
                self.hideNetworkIndicator()
            }
            
            if error != nil {
                
                completion?(nil, error)
            }
            else {
                
                do {
                    
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    
                    completion?(json, nil)
                }
                catch let error2 {
                    
                    completion?(nil, error2)
                }
            }
        })
        
        dataTask.resume()
    }
    
    func post(to url: URL!, data: Data!, customHeader: CustomHeader? = nil, completion: SendCompletionBlockType?) {
        
        DispatchQueue.global(qos: .background).async {
            
            var request = URLRequest(url: url)
            request.configure(for: .post, with: data, customHeader: customHeader)
            
            DispatchQueue.main.async {
                
                self.send(request: request, completion: completion)
            }
        }
    }
    
    func patch(to url: URL!, data: Data!, customHeader: CustomHeader? = nil, completion: SendCompletionBlockType?) {
        
        DispatchQueue.global(qos: .background).async {
            
            var request = URLRequest(url: url)
            request.configure(for: .patch, with: data, customHeader: customHeader)
            
            DispatchQueue.main.async {
                
                self.send(request: request, completion: completion)
            }
        }
    }
    
    func get(from url: URL!, customHeader: CustomHeader? = nil, completion: SendCompletionBlockType?) {
        
        DispatchQueue.global(qos: .background).async {
            
            var request = URLRequest(url: url)
            request.configure(for: .get, with: nil, customHeader: customHeader)
            
            DispatchQueue.main.async {
                
                self.send(request: request, completion: completion)
            }
        }
    }
    
}

internal extension URLRequest {
    
    internal enum HTTPMethod: String {
        
        case post   = "POST"
        case patch  = "PATCH"
        case get    = "GET"
    }
    
    mutating func configure(for method: HTTPMethod, with data: Data? = nil, customHeader: CustomHeader? = nil, jsonContentType: Bool = true) {
        
        httpMethod = method.rawValue
        
        if jsonContentType {
            
            addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let (key, value) = customHeader?() {

            addValue(value, forHTTPHeaderField: key)
        }
        
        httpBody = data
    }
    
}

