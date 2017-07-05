//
//  DatabaseInitializer.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 05/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation

extension CoreDataManager {
    
    static let seedDefaultsKey  = "databaseSeeded"
    
    func seedDatabase() {
        
        if !isDatabaseSeeded() {
            
            let context = createNewManagedObjectContext()
            
            context.perform({

                if let path = Bundle.main.path(forResource: "products", ofType: "json") {
                    
                    do {
                        
                        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                        
                        if let products = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
                 
                            for productObject in products {
                                
                                let product = Product.new(in: context)
                                product.update(with: productObject)
                            }
                            
                            try context.save()
                            
                            self.setDatabaseSeeded(true)
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                } else {
                    print("Invalid filename/path.")
                }
            
            })
        }
    }
    
    private func isDatabaseSeeded() -> Bool {
        
        return UserDefaults.standard.bool(forKey: CoreDataManager.seedDefaultsKey)
    }
    
    private func setDatabaseSeeded(_ seeded: Bool) {
        
        let defaults = UserDefaults.standard
        defaults.set(seeded, forKey: CoreDataManager.seedDefaultsKey)
        defaults.synchronize()
    }
    
    
}
