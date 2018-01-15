//
//  Country+CoreDataProperties.swift
//  CoreDataCountryList
//
//  Created by Mark on 1/14/18.
//  Copyright © 2018 Mark. All rights reserved.
//
//

import Foundation
import CoreData


extension Country {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Country> {
        return NSFetchRequest<Country>(entityName: "Country")
    }

    @NSManaged public var name: String?
    @NSManaged public var capital: String?
    @NSManaged public var icon: NSData?
    @NSManaged public var region: String?
    @NSManaged public var population: Int32

}
