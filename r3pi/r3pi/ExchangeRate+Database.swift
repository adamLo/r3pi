//
//  ExchangeRate+Database.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 05/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation
import CoreData

extension ExchangeRate {
    
    static let entityName   = "ExchangeRate"
    
    private struct JSONkeys {
        
        static let quotes   = "quotes"
        
    }
    
    class func new(in context: NSManagedObjectContext) -> ExchangeRate {
        
        let rateDescription = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        
        let rate = ExchangeRate(entity: rateDescription, insertInto: context)
        
        return rate
    }
    
    class func find(by source: String, destination: String, in context: NSManagedObjectContext) -> ExchangeRate? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "sourceCurrency.shortName = %@ AND destinationCurrency.shortName = %@", source, destination)
        fetchRequest.fetchLimit = 1
        
        do {
            
            if let results = try context.fetch(fetchRequest) as? [ExchangeRate] {
                
                return results.first
            }
        }
        catch {
            print("Error fetching ExchangeRate")
        }
        
        return nil
    }
    
    class func process(json: JSONObject, completion: SuccessCompletionBlockType?) {
        
        if let rateObjects = json[JSONkeys.quotes] as? NSDictionary {
            
            let context = CoreDataManager.sharedInstance.createNewManagedObjectContext()
            
            context.perform({
                
                for (key, value) in rateObjects {
                    
                    if let pairName = key as? String, let rate = value as? Double {
                        
                        let sourceName = (pairName as NSString).substring(to: 3)
                        let destinationName = (pairName as NSString).substring(from: 3)
                        
                        var exchangeRate: ExchangeRate? = ExchangeRate.find(by: sourceName, destination: destinationName, in: context)
                        
                        if exchangeRate == nil {
                            
                            if let sourceCurrency = Currency.find(by: sourceName, in: context), let destinationCurrency = Currency.find(by: destinationName, in: context) {
                                
                                exchangeRate = ExchangeRate.new(in: context)
                                exchangeRate!.sourceCurrency = sourceCurrency
                                exchangeRate!.destinationCurrency = destinationCurrency
                            }
                        }
                        
                        if exchangeRate != nil {
                            
                            exchangeRate!.rate = rate
                            exchangeRate!.updateTime = NSDate()
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
