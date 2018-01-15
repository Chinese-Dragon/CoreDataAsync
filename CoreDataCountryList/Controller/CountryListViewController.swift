//
//  ViewController.swift
//  CoreDataCountryList
//
//  Created by Mark on 1/14/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import UIKit
import CoreData

class CountryListViewController: UIViewController {
	@IBOutlet weak var tableview: UITableView!
	
	lazy var fetchedResultsController: NSFetchedResultsController<Country> = {
		/*Before you can do anything with Core Data, you need a managed object context. */
		let mainContext = CoreDataStack.shareInstance.persistentContainer.viewContext
		
		let request: NSFetchRequest<Country> = Country.fetchRequest()
		
		// Add Sort Descriptors
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		request.sortDescriptors = [sortDescriptor]
		
		// Initialize Fetched Results Controller
		let fetchedResultsController = NSFetchedResultsController<Country>(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
		
		// Configure Fetched Results Controller
		fetchedResultsController.delegate = self
		
		return fetchedResultsController
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		APIClient.shareInstance.fechCountryList { (result) in
			switch result {
			case .Success(let data):
				print("data")
				DispatchQueue.main.async {
					CoreDataStack.shareInstance.insert(with: data)
				}
			case .Error(let errorMsg):
				print(errorMsg)
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		do {
			try fetchedResultsController.performFetch()
		} catch {
			let fetchError = error as NSError
			print("\(fetchError), \(fetchError.localizedDescription)")
		}
	}
}

extension CountryListViewController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let sections = fetchedResultsController.sections else {
			return 0
		}
		
		let sectionInfo = sections[section]
		return sectionInfo.numberOfObjects
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
		
		configureCell(cell, at: indexPath)
		
		return cell
	}
	
	func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
		let country = fetchedResultsController.object(at: indexPath)
		
		// TODO: Configure cell here
		cell.textLabel?.text = country.name
		cell.detailTextLabel?.text = country.capital
	}
}

extension CountryListViewController: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableview.beginUpdates()
	}
	
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		tableview.endUpdates()
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		switch (type) {
		case .insert:
			if let indexPath = newIndexPath {
				tableview.insertRows(at: [indexPath], with: .fade)
			}
			break;
		case .delete:
			if let indexPath = indexPath {
				tableview.deleteRows(at: [indexPath], with: .fade)
			}
			break;
		case .update:
			if let indexPath = indexPath {
				tableview.reloadRows(at: [indexPath], with: .none)
			}
			break;
		case .move:
			if let indexPath = indexPath {
				tableview.deleteRows(at: [indexPath], with: .fade)
			}
			
			if let newIndexPath = newIndexPath {
				tableview.insertRows(at: [newIndexPath], with: .fade)
			}
			break;
		}
	}

}

