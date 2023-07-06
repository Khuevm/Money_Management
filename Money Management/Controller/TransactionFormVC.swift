//
//  TransactionFormVC.swift
//  Money Management
//
//  Created by Khue on 27/05/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol TransactionFormControllerDelegate {
    func sendData(category: Category)
}

class TransactionFormVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var categoryColorView: UIView!
    @IBOutlet weak var categoryiconImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var categoryView: DimableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    
    // MARK: - Variable
    private let user = Auth.auth().currentUser
    var selectedCategory: Category?
    var index = 0
    
    // MARK: - Life Cycle
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
        
        setCategory(selectedCategory!)
        
        //enable keyboard
        amountTextField.becomeFirstResponder()
    }

    // MARK: - IBAction
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func saveButtonDidTap(_ sender: Any) {
        print(datePicker.date)
        let amount = Int(amountTextField.text!) ?? 0
        if amount == 0 {
            showAlertError(error: "Amount has to greater than 0")
            return
        } else if Double(amount) > pow(10,10) {
            showAlertError(error: "Amount is too big")
            return
        }
        
        let transaction = Transaction(id: index, category: selectedCategory!, amount: amount, date: Timestamp(date: datePicker.date), note: noteTextField.text!)
        saveTransaction(transaction)
        self.dismiss(animated: false)
    }
    
    @IBAction func categoryViewDidTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TransactionCategory", bundle: nil)
        let resultVC = storyboard.instantiateViewController(identifier: "TransactionCategory") as TransactionCategoryVC
        
        resultVC.transactionFormDelegate = self
        self.present(resultVC, animated: true, completion: nil)
    }
    
    // MARK: - Firebase
    private func saveTransaction(_ transaction: Transaction) {
        do {
            let email = user?.email
            try Firestore.firestore()
                .collection("user")
                .document(email!)
                .collection("transaction")
                .document("\(transaction.id)")
                .setData(from: transaction)
        } catch let error {
            self.showAlertError(error: error.localizedDescription)
        }
    }
    
    // MARK: - Helper
    func setCategory(_ category: Category){
        selectedCategory = category
        
        categoryName.text = category.name
        categoryColorView.backgroundColor = UIColor(hexString: category.imageColor)
        categoryColorView.layer.cornerRadius = 22
        
        let imageName = K.imageName[category.categoryImageId]
        categoryiconImageView.image = UIImage(named: imageName)
    }
    
    func showAlertError(error: String){
        let alertController = UIAlertController.init(title: "Error", message: error, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Try Again", style: .cancel)
        alertController.addAction(action)
        self.present(alertController, animated: true)
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

extension TransactionFormVC: TransactionFormControllerDelegate {
    func sendData(category: Category) {
        setCategory(category)
    }
    
}
