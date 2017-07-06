//
//  ShoppingCartSummaryViewController.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 06/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import UIKit
import CoreData

class ShoppingCartSummaryViewController: ShoppingCartBaseController {
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var checkoutButton: UIButton!
    
    var checkoutBlock: (() -> ())?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupUI()
        
        calculateCartSummary()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Customization
    
    private func setupUI() {
        
        summaryLabel.font = UIFont.defaultFont(style: .medium, size: 14.0)
        summaryLabel.textColor = UIColor.defaultTextColor
        
        checkoutButton.setTitle(NSLocalizedString("Check out", comment: "Check out button title"), for: .normal)
        checkoutButton.setTitleColor(UIColor.defaultButtonColor, for: .normal)
        checkoutButton.setTitleColor(UIColor.disabledButtonColor, for: .disabled)
        checkoutButton.titleLabel?.font = UIFont.defaultFont(style: .medium, size: 15.0)
    }
    
    // MARK: - Actions
    
    @IBAction func checkoutButtonTouched(_ sender: Any) {
        
        checkoutBlock?()
    }
    
    override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        calculateCartSummary()
    }

    private func calculateCartSummary() {
        
        var numItems = 0
        var sumPrice: Double = 0
        var currency = ""
        
        if let items = cartFetchdResultsController.fetchedObjects as? [BasketItem] {
            
            for item in items {
                
                numItems += 1
                
                if let product = item.product {
                
                    sumPrice += item.amount * product.price
                    
                    if product.currency != nil && currency == "" {
                        
                        currency = product.currency!
                    }
                }
            }
        }
        
        if numItems == 0 {
            
            summaryLabel.text = NSLocalizedString("Your cart is empty!", comment: "Placeholder when shopping cart is empty")
            checkoutButton.isEnabled = false
        }
        else {
            
            summaryLabel.text = String(format: NSLocalizedString("%d products in cart total %0.2f %@", comment: "Shopping cart summary format"), numItems, sumPrice, currency)
            checkoutButton.isEnabled = true
        }
    }
}
