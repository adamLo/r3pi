//
//  BasketItem+CoreDataProperties.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 05/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation
import CoreData


extension BasketItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BasketItem> {
        return NSFetchRequest<BasketItem>(entityName: "BasketItem")
    }

    @NSManaged public var added: NSDate?
    @NSManaged public var amount: Double
    @NSManaged public var product: Product?

}
