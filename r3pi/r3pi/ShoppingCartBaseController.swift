//
//  ShoppingCartBaseController.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 06/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import UIKit
import CoreData

class ShoppingCartBaseController: UIViewController, NSFetchedResultsControllerDelegate {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        fetchItems()
    }

    // MARK: - FetchedResultsController
    
    lazy internal var cartFetchdResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: BasketItem.entityName)
        let sortOrder = NSSortDescriptor(key: "product.name", ascending: true)
        request.sortDescriptors = [sortOrder]
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.sharedInstance.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        return controller
    }()
    
    internal func fetchItems() {
        
        do {
            
            try cartFetchdResultsController.performFetch()
        }
        catch let error {
            
            print("Error fetching BasketItems :\(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }

}
