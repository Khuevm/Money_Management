//
//  CategoryTableViewCell.swift
//  Money Management
//
//  Created by Khue on 25/05/2023.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    
    func setData(category: Category) {
        categoryNameLabel.text = category.name
        colorView.backgroundColor = UIColor(hexString: category.imageColor)
        
        let imageName = K.imageName[category.categoryImageId]
        iconImageView.image = UIImage(named: imageName)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorView.layer.cornerRadius = 22
        iconImageView.tintColor = .white
        categoryView.layer.cornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
