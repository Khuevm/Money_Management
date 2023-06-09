//
//  CategoryFormVC.swift
//  Money Management
//
//  Created by Khue on 26/05/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CategoryFormVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var kindButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Variable
    let user = Auth.auth().currentUser
    var selectedCategory: Category?
    var index: Int = 0
    var selectedImageID = 0
    var selectedColor = "#F8B858"
    var selectedKind = 0
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.setTitle("", for: .normal)
        deleteButton.setTitle("", for: .normal)
        
        let saveAttributedString = NSMutableAttributedString(string: "Save")
        saveAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: NSRange(location: 0, length: saveAttributedString.length))
        saveButton.setAttributedTitle(saveAttributedString, for: .normal)
        
        colorButton.setTitle("", for: .normal)
        colorButton.backgroundColor = UIColor(hexString: selectedColor)
        
        nameTextField.delegate = self
        
        configForm()
        configKindButton()
        configCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Select default image item
        if let selectedImage = collectionView.cellForItem(at: IndexPath(item: selectedImageID, section: 0)) as? CategoryImageCollectionViewCell {
            selectedImage.setSelected(isSelect: true, selectColor: selectedColor)
        }
    }
    
    // MARK: - IBAction
    @IBAction func deleteButtonDidTap(_ sender: Any) {
        deleteCategory(selectedCategory!)
        self.dismiss(animated: false)
    }
    
    @IBAction func saveButtonDidTap(_ sender: Any) {
        let name = nameTextField.text ?? ""
        if name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            self.showAlertError(error: "Missing information")
            return
        }
        
        let category = Category(id: index, name: name, kind: selectedKind, imageColor: selectedColor, categoryImageId: selectedImageID)
        saveCategory(category)
        self.dismiss(animated: false)
    }
    
    @IBAction func colorButtonDidTap(_ sender: Any) {
        //open default ColorPicker
        let colorPicker = UIColorPickerViewController()
        colorPicker.title = "Background Color"
        colorPicker.supportsAlpha = false
        colorPicker.delegate = self
        colorPicker.modalPresentationStyle = .popover
        self.present(colorPicker, animated: true)
    }
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    // MARK: - Firebase
    private func saveCategory(_ category: Category) {
        do {
            let email = user?.email
            try Firestore.firestore()
                .collection("user")
                .document(email!)
                .collection("category")
                .document("\(category.id)")
                .setData(from: category)
        } catch let error {
            self.showAlertError(error: error.localizedDescription)
        }
    }
    
    private func deleteCategory(_ category: Category) {
        let email = user?.email
        Firestore.firestore()
            .collection("user")
            .document(email!)
            .collection("category")
            .document("\(category.id)")
            .delete()
    }
    
    // MARK: - Helper
    func setUpdateData(selectedCategory: Category) {
        self.selectedCategory = selectedCategory
        
        index = selectedCategory.id
        selectedColor = selectedCategory.imageColor
        selectedImageID = selectedCategory.categoryImageId
        selectedKind = selectedCategory.kind
    }
    
    func setAddData(index: Int) {
        self.index = index
    }
    
    private func configCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "CategoryImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryImageCollectionViewCell")
    }
    
    private func configForm(){
        if (self.selectedCategory == nil) {
            deleteButton.isHidden = true
        } else {
            deleteButton.isHidden = false
            
            nameTextField.text = selectedCategory!.name
        }
    }
    
    private func configKindButton(){
        let kindMenuSelect = {(action: UIAction) in
            self.selectedKind = action.title == "Expense" ? 0 : 1
        }
            
        kindButton.menu = UIMenu(children: [
            UIAction(title: "Expense", state: selectedKind == 0 ? .on: .off, handler: kindMenuSelect),
            UIAction(title: "Income", state: selectedKind == 1 ? .on: .off, handler: kindMenuSelect)
        ])
        
        kindButton.showsMenuAsPrimaryAction = true
        
    }
    
    func showAlertError(error: String){
        let alertController = UIAlertController.init(title: "Error", message: error, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Try Again", style: .cancel)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CategoryFormVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //dismiss keyboard
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIColorPickerViewControllerDelegate
extension CategoryFormVC: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        colorButton.backgroundColor = color
        selectedColor = color.hexStringFromColor()
        
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegate
extension CategoryFormVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let oldSelected = IndexPath(item: selectedImageID, section: 0)
        if let oldSelectedImage = collectionView.cellForItem(at: oldSelected) as? CategoryImageCollectionViewCell {
            oldSelectedImage.setSelected(isSelect: false, selectColor: selectedColor)
        }
        
        if let selectedImage = collectionView.cellForItem(at: indexPath) as? CategoryImageCollectionViewCell {
            selectedImage.setSelected(isSelect: true, selectColor: selectedColor)
        }
        selectedImageID = indexPath.row
        
    }
}

// MARK: - UICollectionViewDataSource
extension CategoryFormVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return K.imageName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryImageCollectionViewCell", for: indexPath) as! CategoryImageCollectionViewCell
        cell.setData(categoryImageId: indexPath.row, isSelected: selectedImageID == indexPath.row, selectColor: selectedColor)
        return cell
        
    }
    
    
}
