//
//  Product+Database.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 05/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation
import CoreData

extension Product {
    
    static let entityName   = "Product"
    
    private struct JSONkeys {
        
        static let name     = "name"
        static let unit     = "unit"
        static let price    = "price"
        static let currency = "currency"
    }
    
    class func newProduct(in context: NSManagedObjectContext) -> Product {
        
        let productDescription = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        
        let product = Product(entity: productDescription, insertInto: context)
        
        return product
    }
    
    func update(with json: [String: Any]) {
        
        if let nameValue = json[JSONkeys.name] as? String {
         
            name = nameValue
        }
        
        if let currencyValue = json[JSONkeys.currency] as? String {
            
            currency = currencyValue
        }
        
        if let unitValue = json[JSONkeys.unit] as? String {
            
            unit = unitValue
        }
        
        if let priceValue = json[JSONkeys.price] as? Double {
            
            price = priceValue
        }
    }
}
