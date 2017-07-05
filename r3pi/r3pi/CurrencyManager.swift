//
//  CurrencyManager.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 05/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation

extension NetworkManager {
    
    private struct Configuration {
        
        static let baseURL  = URL(string: "http://apilayer.net/api")!
        
        static let apiKeyName   = "access_key"
        static let apiKeyValue  = "79387116d6cdb40e31d2a09f00078946"
        
        static let list         = "list"
        static let live         = "live"
    }
    
    func updateRates(Completion completion: SuccessCompletionBlockType?) {
        
        
    }
    
    func fetchCurrencies(Completion completion: SuccessCompletionBlockType?) {
        
        var urlComponents = URLComponents(url: Configuration.baseURL.appendingPathComponent(Configuration.list), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [URLQueryItem(name: Configuration.apiKeyName, value: Configuration.apiKeyValue)]
        
        let url = urlComponents.url!
        
        get(from: url) { (results, error) in
            
            if error == nil, let data = results as? JSONObject {
                
                Currency.process(json: data, completion: completion)
            }
            else {
                
                completion?(false, error)
            }
        }
    }
}
