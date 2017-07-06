//
//  ProductCell.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 06/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {
    
    static let reuseId = "productCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cartButton: UIButton!
    
    var addButtonTouchedBlock: (() -> ())?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        titleLabel.font = UIFont.defaultFont(style: .medium, size: 13.0)
        titleLabel.textColor = UIColor.defaultTextColor
        
        priceLabel.font = UIFont.defaultFont(style: .regular, size: 11.0)
        priceLabel.textColor = UIColor.defaultTextColor
        
        cartButton.setTitle(NSLocalizedString("+ Add To Cart", comment: "Add to cart button title"), for: .normal)
        cartButton.titleLabel?.font = UIFont.defaultFont(style: .regular, size: 13.0)
        cartButton.setTitleColor(UIColor.defaultButtonColor, for: .normal)
    }

    func setup(with product: Product) {
        
        titleLabel.text = product.name
        priceLabel.text = String(format: NSLocalizedString("%@ %0.2f per %@", comment: "Product price format"), product.currency ?? "N/A", product.price, product.unit ?? "N/A")
    }
    
    @IBAction func cartButtonTouched(_ sender: Any) {
        
        addButtonTouchedBlock?()
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        addButtonTouchedBlock = nil
    }
}
