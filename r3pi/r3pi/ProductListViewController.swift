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
    
    @IBOutlet weak var cartSummaryHolder: UIView!
    @IBOutlet weak var cartSummaryHeight: NSLayoutConstraint!
    
    private weak var cartSummaryController: ShoppingCartSummaryViewController?
    
    private struct Segue {
        
        static let cartSummary  = "cartSummary"
        static let checkout     = "checkout"
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        setupUI()
        
        fetchProducts()
    }
    
    override func viewDidLayoutSubviews() {
        
        productsTableView.contentInset = UIEdgeInsets(top: cartSummaryHeight.constant, left: 0, bottom: 0, right: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
     
        super.viewDidAppear(animated)
        
        cartSummaryController?.forceRefresh()
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
    
    // MARK: - Actions
    
    private func addToCart(product: Product) {
        
        BasketItem.addToCart(product: product)
        
        cartSummaryController?.forceRefresh()
    }
    
    private func checkout() {
        
        performSegue(withIdentifier: Segue.checkout, sender: self)
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
            
            cell.addButtonTouchedBlock = {() in
                
                self.addToCart(product: product)
            }
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        productsTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert: productsTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete: productsTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update: productsTableView.reloadRows(at: [indexPath!], with: .automatic)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        productsTableView.endUpdates()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segue.cartSummary {
            
            cartSummaryController = segue.destination as? ShoppingCartSummaryViewController
            
            cartSummaryController!.checkoutBlock = {() in
                
                self.checkout()
            }
        }
    }
}
