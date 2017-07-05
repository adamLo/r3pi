//
//  Product+CoreDataProperties.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 05/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var currency: String?
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var unit: String?
    @NSManaged public var basket: BasketItem?

}
