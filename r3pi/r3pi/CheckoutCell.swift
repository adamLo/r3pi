//
//  CheckoutCell.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 06/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import UIKit

class CheckoutCell: UITableViewCell {
    
    static let reuseId = "cartCell"
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    var plusBlock: (() -> ())?
    var minusBlock: (() -> ())?
    
    override func awakeFromNib() {
    
        super.awakeFromNib()
        
        productNameLabel.font = UIFont.defaultFont(style: .medium, size: 13.0)
        productNameLabel.textColor = UIColor.defaultTextColor
        
        productPriceLabel.font = UIFont.defaultFont(style: .regular, size: 11.0)
        productPriceLabel.textColor = UIColor.defaultTextColor
        
        amountLabel.font = UIFont.defaultFont(style: .regular, size: 13.0)
        amountLabel.textColor = UIColor.defaultTextColor
        
        totalPriceLabel.font = UIFont.defaultFont(style: .medium, size: 13.0)
        totalPriceLabel.textColor = UIColor.defaultTextColor
        
        plusButton.setTitle(NSLocalizedString("+", comment: "Increase amouint button title"), for: .normal)
        plusButton.titleLabel?.font = UIFont.defaultFont(style: .bold, size: 20.0)
        plusButton.setTitleColor(UIColor.white, for: .normal)
        plusButton.backgroundColor = UIColor.darkGray
        
        minusButton.setTitle(NSLocalizedString("-", comment: "Decrease amouint button title"), for: .normal)
        minusButton.titleLabel?.font = UIFont.defaultFont(style: .bold, size: 20.0)
        minusButton.setTitleColor(UIColor.white, for: .normal)
        minusButton.backgroundColor = UIColor.darkGray
    }

    func setup(with basketItem: BasketItem) {
        
        var itemPrice: Double = 0
        if let product = basketItem.product {
        
            productNameLabel.text = product.name
            productPriceLabel.text = String(format: NSLocalizedString("%@ %0.2f per %@", comment: "Product price format"), product.currency ?? "N/A", product.price, product.unit ?? "N/A")
            itemPrice = product.price
        }
        else {
            
            productNameLabel.text = "N/A"
            productPriceLabel.text = "N/A"
        }
        
        amountLabel.text = String(format: "%0.0f", basketItem.amount)
        
        totalPriceLabel.text = String(format: "%0.2f", itemPrice * basketItem.amount)
    }
    
    @IBAction func plusButtonTouched(_ sender: Any) {
        
        plusBlock?()
    }
    
    @IBAction func minusButtonTouched(_ sender: Any) {
        
        minusBlock?()
    }

    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        plusBlock = nil
        minusBlock = nil
    }
}
