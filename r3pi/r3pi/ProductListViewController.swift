//
//  ProductListViewController.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 06/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import UIKit
import CoreData

class ProductListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var productsTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        
        fetchProducts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Customization
    
    private func setupUI() {
        
        title = "R3Pi WebShop"
        
        setupTableview()
    }
    
    private func setupTableview() {
        
        productsTableView.tableFooterView = UIView()
    }

    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let objects = productsFetchdResultsController.fetchedObjects {
            
            return objects.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.reuseId, for: indexPath) as! ProductCell
        
        if let products = productsFetchdResultsController.fetchedObjects as? [Product] {
            
            let product = products[indexPath.row]
            
            cell.setup(with: product)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    // MARK: - FetchedResultsController
    
    lazy private var productsFetchdResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Product.entityName)
        let sortOrder = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [sortOrder]
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.sharedInstance.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        return controller
    }()
    
    private func fetchProducts() {
     
        do {
            
            try productsFetchdResultsController.performFetch()
        }
        catch let error {
            
            print("Error fetching products :\(error)")
        }
    }
    

}
