//
//  TransactionFormVC.swift
//  Money Management
//
//  Created by Khue on 27/05/2023.
//

import UIKit

class TransactionFormVC: UIViewController {
    @IBOutlet weak var categoryColorView: UIView!
    @IBOutlet weak var categoryiconImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryView: DimableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.setTitle("", for: .normal)
        deleteButton.setTitle("", for: .normal)
        
        let saveAttributedString = NSMutableAttributedString(string: "Save")
        saveAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: NSRange(location: 0, length: saveAttributedString.length))
        saveButton.setAttributedTitle(saveAttributedString, for: .normal)
        
        categoryView.layer.cornerRadius = 20

        noteTextField.delegate = self
        amountTextField.delegate = self
        amountTextField.becomeFirstResponder()
    }

    @IBAction func backButtonDidTap(_ sender: Any) {
        self.dismiss(animated: false)
    }
    @IBAction func categoryViewDidTap(_ sender: Any) {
    }
    @IBAction func dateViewDidTap(_ sender: Any) {
    }
}

// MARK: - UITextFieldDelegate
extension TransactionFormVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //dismiss keyboard
        textField.resignFirstResponder()
        return true
    }
}


