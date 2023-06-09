//
//  CategoryImageCollectionViewCell.swift
//  Money Management
//
//  Created by Khue on 27/05/2023.
//

import UIKit

class CategoryImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = 22
    }

    func setData(categoryImageId: Int, isSelected: Bool, selectColor: String) {
        let image = K.imageName[categoryImageId]
        categoryImage.image = UIImage(named: image)
        
        setSelected(isSelect: isSelected, selectColor: selectColor)
    }
    
    func setSelected(isSelect: Bool, selectColor: String) {
        if (isSelect) {
            categoryImage.tintColor = .white
            view.backgroundColor = UIColor(hexString: selectColor)
        } else {
            categoryImage.tintColor = .black
            view.backgroundColor = .white
        }
    }
}
