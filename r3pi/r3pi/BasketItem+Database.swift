//
//  BasketItem+Database.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 06/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation
import CoreData

extension BasketItem {
    
    static let entityName   = "BasketItem"
    
    class func addToCart(product: Product) {
        
        let context = CoreDataManager.sharedInstance.createNewManagedObjectContext()
        let productId = product.objectID
        
        context.perform {
            
            do {
                
                let product = try context.existingObject(with: productId) as! Product
                
                var item = find(by: product, in: context)
                
                if item == nil {
                    
                    item = new(in: context)
                    item!.product = product
                }
                
                item!.amount += 1
                item!.added = NSDate()
                
                try context.save()
            }
            catch let error {
                
                print("Error \(error)")
            }
        }
    }
    
    class func find(by product: Product, in context: NSManagedObjectContext) -> BasketItem? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "product = %@", product)
        fetchRequest.fetchLimit = 1
        
        do {
            
            if let results = try context.fetch(fetchRequest) as? [BasketItem] {
                
                return results.first
            }
        }
        catch let error {
            print("Error fetching BasketItems \(error)")
        }
        
        return nil
    }
    
    class func new(in context: NSManagedObjectContext) -> BasketItem {
        
        let itemDescription = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        
        let item = BasketItem(entity: itemDescription, insertInto: context)
        
        return item
    }
    
    class func clearCart() {
    
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        
        let context = CoreDataManager.sharedInstance.createNewManagedObjectContext()
        context.perform {
            
            do {
                
                let items = try context.fetch(fetchRequest) as! [BasketItem]
                
                for item in items {
                    
                    context.delete(item)
                }
                
                try context.save()
            }
            catch let error {
                
                print("Error executing fetch request \(error)")
            }
        }
    }
    
}
