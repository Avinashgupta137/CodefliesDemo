//
//  ProductCollectionViewCell.swift
//  CodefliesDemo
//
//  Created by Avinash Gupta on 31/03/25.
//

import UIKit
import SDWebImage

class ProductCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    func configure(with category: (name: String, imageUrl: String, price: String)) {
        nameLabel.text = category.name
        priceLabel.text = category.price
        imageView.sd_setImage(with: URL(string: category.imageUrl), placeholderImage: UIImage(named: "placeholder"))
    }
}
