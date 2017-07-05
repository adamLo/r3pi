//
//  Currency+CoreDataProperties.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 05/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation
import CoreData


extension Currency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Currency> {
        return NSFetchRequest<Currency>(entityName: "Currency")
    }

    @NSManaged public var longNam: String?
    @NSManaged public var shortName: String?
    @NSManaged public var rateDestination: NSSet?
    @NSManaged public var rateSource: NSSet?

}

// MARK: Generated accessors for rateDestination
extension Currency {

    @objc(addRateDestinationObject:)
    @NSManaged public func addToRateDestination(_ value: ExchangeRate)

    @objc(removeRateDestinationObject:)
    @NSManaged public func removeFromRateDestination(_ value: ExchangeRate)

    @objc(addRateDestination:)
    @NSManaged public func addToRateDestination(_ values: NSSet)

    @objc(removeRateDestination:)
    @NSManaged public func removeFromRateDestination(_ values: NSSet)

}

// MARK: Generated accessors for rateSource
extension Currency {

    @objc(addRateSourceObject:)
    @NSManaged public func addToRateSource(_ value: ExchangeRate)

    @objc(removeRateSourceObject:)
    @NSManaged public func removeFromRateSource(_ value: ExchangeRate)

    @objc(addRateSource:)
    @NSManaged public func addToRateSource(_ values: NSSet)

    @objc(removeRateSource:)
    @NSManaged public func removeFromRateSource(_ values: NSSet)

}
