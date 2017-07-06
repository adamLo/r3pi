//
//  CurrencyViewController.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 06/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import UIKit
import CoreData

class CurrencyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var currencyTableView: UITableView!
    
    var currencySelectedBlock: ((_ currency: Currency?) -> ())?
    
    var sourceCurrencyName: String = "USD"
    private var sourceCurrency: Currency?
    
    private let cellReuseId = "currencyCell"
    
    private lazy var dateFormatter: DateFormatter = {
       
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        
        return formatter
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        title = NSLocalizedString("Currencies", comment: "Currency selector navigation title")
        
        if sourceCurrencyName.characters.count > 0 {
            
            sourceCurrency = Currency.find(by: sourceCurrencyName, in: CoreDataManager.sharedInstance.managedObjectContext!)
        }
        
        fetchCurrencies()
        
        NetworkManager.sharedInstance.fetchCurrencies(Completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - FetchedResultsController
    
    lazy private var currencyFetchdResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Currency.entityName)
        let sortOrder = NSSortDescriptor(key: "longName", ascending: true)
        request.sortDescriptors = [sortOrder]
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: CoreDataManager.sharedInstance.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        return controller
    }()
    
    private func fetchCurrencies() {
        
        do {
            
            try currencyFetchdResultsController.performFetch()
        }
        catch let error {
            
            print("Error fetching currencies: \(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        currencyTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert: currencyTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete: currencyTableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update: currencyTableView.reloadRows(at: [indexPath!], with: .automatic)
        default: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        currencyTableView.endUpdates()
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let objects = currencyFetchdResultsController.fetchedObjects {
            
            return objects.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId)
        if cell == nil {
            
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellReuseId)
            
            cell!.textLabel?.font = UIFont.defaultFont(style: .regular, size: 13.0)
            cell!.textLabel?.textColor = UIColor.defaultTextColor
            
            cell!.detailTextLabel?.font = UIFont.defaultFont(style: .regular, size: 11.0)
            cell!.detailTextLabel?.textColor = UIColor.defaultTextColor
            
            cell!.tintColor = UIColor.defaultTextColor
        }
        
        if let currencies = currencyFetchdResultsController.fetchedObjects as? [Currency] {
            
            let currency = currencies[indexPath.row]
            
            cell!.textLabel!.text = String(format: "%@ (%@)", currency.longName ?? "N/A", currency.shortName ?? "N/A")
            
            if sourceCurrency != nil, let exchangeRate = ExchangeRate.find(by: sourceCurrency!, destination: currency, in: CoreDataManager.sharedInstance.managedObjectContext!) {
                
                let dateString = exchangeRate.updateTime != nil ? dateFormatter.string(from: exchangeRate.updateTime! as Date) : "N/A"
                
                cell!.detailTextLabel!.text = String(format: "%0.3f updated %@", exchangeRate.rate, dateString)
            }
            else {
                
                cell!.detailTextLabel!.text = nil
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let currencies = currencyFetchdResultsController.fetchedObjects as? [Currency] {
            
            let currency = currencies[indexPath.row]
            
            currencySelectedBlock?(currency)
            
            navigationController?.popViewController(animated: true)
        }
    }
}
