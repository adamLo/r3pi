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
    @IBOutlet weak var rateActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var exchangeRateLabel: UILabel!
    
    private struct Segue {
        
        static let switchCurrency = "switchCurrency"
    }
    
    private var selectedCurrency: Currency? {
        
        didSet {
            
            self.updateExchangeRate()
        }
    }
    
    private var exchangeRate: Double = 1.0 {
        
        didSet {
            
            self.calculateTotal()
            
            if exchangeRate != 1.0 {
                
                exchangeRateLabel.text = String(format: NSLocalizedString("Exchange rate: %0.3f", comment: "Exchnage rate format"), exchangeRate)
                exchangeRateLabel.isHidden = false
            }
            else {
               
                exchangeRateLabel.isHidden = true
            }
        }
    }
    
    private var sourceCurrencyName = "USD"
    
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
    
    private func setupTotal() {
        
        totalLabel.font = UIFont.defaultFont(style: .medium, size: 13.0)
        totalLabel.textColor = UIColor.defaultTextColor
        totalLabel.text = NSLocalizedString("Total:", comment: "Total sum title")
        
        totalPriceLabel.font = UIFont.defaultFont(style: .bold, size: 13.0)
        totalPriceLabel.textColor = UIColor.defaultTextColor
        
        switchCurrencyButton.titleLabel?.font = UIFont.defaultFont(style: .medium, size: 13.0)
        switchCurrencyButton.setTitleColor(UIColor.defaultButtonColor, for: .normal)
        
        exchangeRateLabel.font = UIFont.defaultFont(style: .light, size: 10.0)
        exchangeRateLabel.textColor = UIColor.defaultTextColor
        exchangeRateLabel.isHidden = true
        
        clearCartButton.setTitle(NSLocalizedString("Clear cart", comment: "Cleart cart button title"), for: .normal)
        clearCartButton.titleLabel?.font = UIFont.defaultFont(style: .medium, size: 13.0)
        clearCartButton.setTitleColor(UIColor.defaultButtonColor, for: .normal)
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
        
        performSegue(withIdentifier: Segue.switchCurrency, sender: sender)
    }
    
    @IBAction func clearCartTouched(_ sender: Any) {
        
        let alert = UIAlertController(title: NSLocalizedString("Clear cart", comment: "Clear cart alert title"), message: NSLocalizedString("Are you sure?", comment: "Clear cart alert message"), preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes, clear", comment: "Clear cart confirmation title"), style: .destructive, handler: { (action) in
            
            BasketItem.clearCart()
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Clear cart cancel title"), style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)                
    }
    
    // MARK: - Calculation
    
    private func calculateTotal() {
        
        var totalPrice: Double = 0
        var currencyName = selectedCurrency != nil && selectedCurrency!.shortName != nil ? selectedCurrency!.shortName : ""
        
        if let items = cartFetchdResultsController.fetchedObjects as? [BasketItem] {
            
            for item in items {
                
                if let product = item.product {
                    
                    totalPrice += item.amount * product.price * exchangeRate
                    
                    if product.currency != nil && product.currency!.characters.count > 0 {
                        
                        if currencyName == "" {
                        
                            currencyName = product.currency!
                        }
                        
                        sourceCurrencyName = product.currency!
                    }
                }
            }
        }

        if currencyName == "" {
            
            currencyName = "N/A"
        }
        
        totalPriceLabel.text = String(format: "%0.2f", totalPrice)
        switchCurrencyButton.setTitle(currencyName, for: .normal)
        
        exchangeRateLabel.isHidden = exchangeRate == 1.0
    }
    
    private func updateExchangeRate() {

        if selectedCurrency != nil && selectedCurrency!.shortName != nil && selectedCurrency!.shortName != sourceCurrencyName {
        
            rateActivityIndicator.startAnimating()
            
            let targetCurrencyName = selectedCurrency!.shortName!.uppercased()
            
            NetworkManager.sharedInstance.updateRates(source: sourceCurrencyName, currencies: [targetCurrencyName]) {[weak self] (success, error) in
                
                if self != nil {
                
                    DispatchQueue.main.async {
                        
                        self!.rateActivityIndicator.stopAnimating()
                    }
                    
                    if success {
                        
                        let context = CoreDataManager.sharedInstance.createNewManagedObjectContext()
                        
                        context.perform({
                        
                            if let sourceCurrency = Currency.find(by: self!.sourceCurrencyName, in: context) {
                                
                                if let targetCurrency = Currency.find(by: targetCurrencyName, in: context) {
                            
                                    if let rate = ExchangeRate.find(by: sourceCurrency, destination: targetCurrency, in: context) {
                                        
                                        let _rate = rate.rate
                    
                                        DispatchQueue.main.async {
                                        
                                            self!.exchangeRate = _rate
                                        }
                                    }
                                }
                            }
                        })
                    }
                    else {
                        
                        DispatchQueue.main.async {
                            
                            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error dialog titl"), message: NSLocalizedString("Error updating exchange rate", comment: "Error mssag when exchange rate updat failed"), preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            
                            self!.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        else {
            
            exchangeRate = 1.0
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segue.switchCurrency {
            
            let target = segue.destination as! CurrencyViewController
            
            target.sourceCurrencyName = self.sourceCurrencyName
            
            target.currencySelectedBlock = {(currency) in
                
                if currency != nil {
                    
                    self.selectedCurrency = currency!
                }
            }
        }
    }
}
