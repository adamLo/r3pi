//
//  ExchangeRate+CoreDataProperties.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 05/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation
import CoreData


extension ExchangeRate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExchangeRate> {
        return NSFetchRequest<ExchangeRate>(entityName: "ExchangeRate")
    }

    @NSManaged public var rate: Double
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var destinationCurrency: Currency?
    @NSManaged public var sourceCurrency: Currency?

}
