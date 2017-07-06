//
//  CheckoutViewController.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 06/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import UIKit
import CoreData

class CheckoutViewController: ShoppingCartBaseController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var itemsTableView: UITableView!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var switchCurrencyButton: UIButton!
    @IBOutlet weak var clearCartButton: UIButton!
    
    private var selectedCurrency: Currency? {
        
        didSet {
            
            self.calculateTotal()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Check out", comment: "Check out screen navigation title")
        
        setupUI()
        
        calculateTotal()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Customization
    
    private func setupUI() {
        
    }
    
    // MARK: - Tableview
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let objects = cartFetchdResultsController.fetchedObjects {
            
            return objects.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CheckoutCell.reuseId, for: indexPath) as! CheckoutCell
        
        if let items = cartFetchdResultsController.fetchedObjects as? [BasketItem] {
            
            let item = items[indexPath.row]
            
            cell.setup(with: item)
            
            cell.plusBlock = {() in
        
                self.increaseAmount(of: item)
            }
            
            cell.minusBlock = {() in
                
                self.decreaseAmount(of: item)
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
    
    override func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        itemsTableView.beginUpdates()
    }
    
    override func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert: itemsTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete: itemsTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update: itemsTableView.reloadRows(at: [indexPath!], with: .automatic)
        default: break
        }
    }
    
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        itemsTableView.endUpdates()
        
        calculateTotal()
    }

    // MARK: - Actions
    
    private func increaseAmount(of item: BasketItem) {
        
        if let context = item.managedObjectContext {
        
            context.perform {
                
                item.amount += 1
                
                do {
                    
                    try context.save()
                }
                catch let error {
                    
                    print("Error saving context \(error)")
                }
            }
        }
    }
    
    private func decreaseAmount(of item: BasketItem) {
        
        if item.amount > 1 {
        
            if let context = item.managedObjectContext {
                
                context.perform {
                    
                    item.amount -= 1
                    
                    do {
                        
                        try context.save()
                    }
                    catch let error {
                        
                        print("Error saving context \(error)")
                    }
                }
            }
        }
        else {
            
            let alert = UIAlertController(title: NSLocalizedString("Delete item", comment: "Delete item alert title"), message: NSLocalizedString("Are you sure?", comment: "Delete item alert message"), preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes, delete", comment: "Delete item confirmation title"), style: .destructive, handler: { (action) in
                
                if let context = item.managedObjectContext {
                    
                    context.perform {
                        
                        context.delete(item)
                        
                        do {
                            
                            try context.save()
                        }
                        catch let error {
                            
                            print("Error saving context \(error)")
                        }
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Delete item cancel title"), style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func switchCurrencyTouched(_ sender: Any) {
    }
    
    @IBAction func clearCartTouched(_ sender: Any) {
    }
    
    // MARK: - Calculation
    
    private func calculateTotal() {
        
        var totalPrice: Double = 0
        var currencyName = selectedCurrency != nil && selectedCurrency!.shortName != nil ? selectedCurrency!.shortName : ""
        var exchangeRate: Double = 1.0
        
        if let items = cartFetchdResultsController.fetchedObjects as? [BasketItem] {
            
            for item in items {
                
                if let product = item.product {
                    
                    totalPrice += item.amount * product.price * exchangeRate
                    
                    if currencyName == "" && product.currency != nil {
                        
                        currencyName = product.currency!
                    }
                }
            }
        }

        if currencyName == "" {
            
            currencyName = "N/A"
        }
        
        totalPriceLabel.text = String(format: "%0.2f", totalPrice)
        switchCurrencyButton.setTitle(currencyName, for: .normal)
    }
}
