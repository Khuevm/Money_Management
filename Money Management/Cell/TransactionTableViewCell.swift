//
//  TransactionTableViewCell.swift
//  Money Management
//
//  Created by Khue on 27/05/2023.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var amountLabel: UILabel!
    
    func setData(transaction: Transaction) {
        noteLabel.text = transaction.note
        noteLabel.isHidden = transaction.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        let category = transaction.category
        categoryNameLabel.text = category.name
        colorView.backgroundColor = UIColor(hexString: category.imageColor)
        
        let imageName = K.imageName[category.categoryImageId]
        iconImageView.image = UIImage(named: imageName)
        
        let amount = transaction.amount
        if category.kind == 0 {
            amountLabel.text = "- \(amount)"
            amountLabel.textColor = UIColor(named: "RedColor")
        } else {
            amountLabel.text = "+ \(amount)"
            amountLabel.textColor = UIColor(named: "GreenColor")
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorView.layer.cornerRadius = 22
        iconImageView.tintColor = .white
        view.layer.cornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
