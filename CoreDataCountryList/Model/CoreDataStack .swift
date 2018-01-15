//
//  CoreDataStack .swift
//  CoreDataCountryList
//
//  Created by Mark on 1/14/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataStack: NSObject {
	static let shareInstance = CoreDataStack()
	private override init() {}
	
	private let saveFrequencyCount = 300
	
	// MARK: - Core Data stack
	lazy var persistentContainer: NSPersistentContainer = {
		/*
		The persistent container for the application. This implementation
		creates and returns a container, having loaded the store for the
		application to it. This property is optional since there are legitimate
		error conditions that could cause the creation of the store to fail.
		*/
		let container = NSPersistentContainer(name: "CoreDataCountryList")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				
				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}()
	
	// MARK: - Core Data Saving support
	func saveContext () {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	func insert(with countryDicts: [[String: Any]]) {
		persistentContainer.performBackgroundTask { [weak self] (backgroundContext) in
			guard let strongSelf = self else { return }
			
			print(countryDicts.count)
			for (i, countryDict) in countryDicts.enumerated() {
				// parsing
				guard let name = countryDict["name"] as? String,
					let capital = countryDict["capital"] as? String,
					let iconUrlStr = countryDict["flag"] as? String,
					let _ = URL(string: iconUrlStr),
					let population = countryDict["population"] as? Int,
					let region = countryDict["region"] as? String else {
						return
				}
				
				// go get image data (syncrhous) will block current thread, but since it's not Main Queue so ....
				// ???????? better way??????
//				let flagIcon = UIImage(
//				let imgData = UIImageJPEGRepresentation(diaryImage.image!, 1)
//
				
				// construct single model obj and insert to private context
				let newCountry = Country(context: backgroundContext)
				newCountry.setValue(name, forKey: "name")
				newCountry.setValue(capital, forKey: "capital")
				newCountry.setValue(population, forKey: "population")
				newCountry.setValue(region, forKey: "region")
				
				if i % strongSelf.saveFrequencyCount == 0 {
					print(i)
					// periodic save
					try! backgroundContext.save()
					backgroundContext.reset()
					strongSelf.persistentContainer.viewContext.perform {
						strongSelf.saveContext()
					}
				}
			}
			
			// save the rest that is not saved while doing periodic save
			try! backgroundContext.save()
			backgroundContext.reset()
			strongSelf.persistentContainer.viewContext.perform {
				strongSelf.saveContext()
			}
		}
	}
}
