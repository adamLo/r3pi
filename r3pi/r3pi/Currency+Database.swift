//
//  Currency+Database.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 05/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation
import CoreData

extension Currency {
    
    static let entityName       = "Currency"
    static let idKey            = "shortName"
    
    private struct JSONkeys {
        
        static let currencies   = "currencies"
        
    }
    
    class func new(in context: NSManagedObjectContext) -> Currency {
        
        let currencyDescription = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        
        let currency = Currency(entity: currencyDescription, insertInto: context)
        
        return currency
    }
    
    class func find(by id: String, in context: NSManagedObjectContext) -> Currency? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "\(idKey) = %@", id)
        fetchRequest.fetchLimit = 1
        
        do {
            
            if let results = try context.fetch(fetchRequest) as? [Currency] {
                
                return results.first
            }
        }
        catch {
            print("Error fetching Currency")
        }
        
        return nil
    }
    
    class func process(json: JSONObject, completion: SuccessCompletionBlockType?) {
        
        if let currencyObjects = json[JSONkeys.currencies] as? NSDictionary {
        
            let context = CoreDataManager.sharedInstance.createNewManagedObjectContext()
            
            context.perform({
                
                for (key, value) in currencyObjects {
                    
                    if let shortName = key as? String, let longName = value as? String {
                    
                        var currency: Currency? = Currency.find(by: shortName, in: context)
                        
                        if currency == nil {
                            
                            currency = Currency.new(in: context)
                        }
                        
                        if currency != nil {
                            
                            currency!.shortName = shortName
                            currency!.longName = longName
                        }
                    }
                    
                    do {
                        
                        if context.hasChanges {
                            
                            try context.save()
                        }
                        
                        completion?(true, nil)
                    }
                    catch let error {
                        
                        completion?(false, error)
                    }
                }
            })
        }
        else {
            
            completion?(false, nil)
        }
    }
}
