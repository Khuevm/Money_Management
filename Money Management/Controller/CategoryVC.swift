//
//  CategoryVC.swift
//  Money Management
//
//  Created by Khue on 23/05/2023.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class CategoryVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variable
    let db = Firestore.firestore()
    var user = Auth.auth().currentUser
    private var categories: [Category] = []
    private var categoriesByKind: [Category] = []
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.setTitle("", for: .normal)
        
        configTableView()
        getAllCategory()
    }
    
    // MARK: - IBAction
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        getCategoryByKind(kind: sender.selectedSegmentIndex)
    }
    
    @IBAction func addButtonDidTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CategoryForm", bundle: nil)
        let resultVC = storyboard.instantiateViewController(identifier: "CategoryForm") as CategoryFormVC
        resultVC.setAddData(index: (categories.last?.id ?? -1) + 1) //if have no cate -> newcate id = 0
        
        resultVC.modalPresentationStyle = .fullScreen
        self.present(resultVC, animated: false, completion: nil)
    }
    
    // MARK: - Helper
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryTableViewCell")
    }
    
    // MARK: - Firebase
    private func getAllCategory(){
        categories.removeAll()
        
        let email = user?.email
        let categoryListRef = db.collection("user")
            .document("\(email!)")
            .collection("category")
            .order(by: "id");
        categoryListRef.addSnapshotListener { querySnapshot, error in
            self.user = Auth.auth().currentUser
            if self.user != nil, let snapshot = querySnapshot {
                snapshot.documentChanges.forEach { diff in
                    do {
                        switch diff.type {
                        case .added:
                            let category = try diff.document.data(as: Category.self)
                            self.categories.append(category)
                            
                        case .modified:
                            let modifiedCategory = try diff.document.data(as: Category.self)
                            if let index = self.categories.firstIndex(where: { category in
                                category.id == modifiedCategory.id
                            }) {
                                self.updateTransaction(with: modifiedCategory)
                                self.categories[index] = modifiedCategory
                            }
                            
                        case .removed:
                            let removeCategory = try diff.document.data(as: Category.self)
                            self.categories.removeAll { category in
                                category.id == removeCategory.id
                            }
                            self.removeTransaction(with: removeCategory)
                        }
                        
                        self.getCategoryByKind(kind: self.segment.selectedSegmentIndex)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }

    }
    
    private func updateTransaction(with category: Category) {
        let email = user?.email
        db.collection("user")
            .document("\(email!)")
            .collection("transaction")
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print(err.localizedDescription)
                } else {
                    do {
                        for document in querySnapshot!.documents {
                            var transaction = try document.data(as: Transaction.self)
                            if transaction.category.id == category.id {
                                transaction.category = category
                                
                                try Firestore.firestore()
                                    .collection("user")
                                    .document(email!)
                                    .collection("transaction")
                                    .document("\(transaction.id)")
                                    .setData(from: transaction)
                            }
                            
                        }
                    } catch let err {
                        print(err)
                    }
                }
            }
    }
    
    private func removeTransaction(with category: Category) {
        let email = user?.email
        db.collection("user")
            .document("\(email!)")
            .collection("transaction")
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print(err.localizedDescription)
                } else {
                    do {
                        for document in querySnapshot!.documents {
                            var transaction = try document.data(as: Transaction.self)
                            if transaction.category.id == category.id {
                                try Firestore.firestore()
                                    .collection("user")
                                    .document(email!)
                                    .collection("transaction")
                                    .document("\(transaction.id)")
                                    .delete()
                            }
                            
                        }
                    } catch let err {
                        print(err)
                    }
                }
            }
    }
    
    // MARK: - Helper
    private func getCategoryByKind(kind: Int){
        categoriesByKind.removeAll()
        categoriesByKind = categories.filter(){
            $0.kind == kind
        }
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension CategoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let storyboard = UIStoryboard(name: "CategoryForm", bundle: nil)
        let resultVC = storyboard.instantiateViewController(identifier: "CategoryForm") as CategoryFormVC
        resultVC.setUpdateData(selectedCategory: categoriesByKind[indexPath.row])
        
        resultVC.modalPresentationStyle = .fullScreen
        self.present(resultVC, animated: false, completion: nil)
    }
    
}

// MARK: - UITableViewDataSource
extension CategoryVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesByKind.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
        cell.setData(category: categoriesByKind[indexPath.row])
        return cell
    }
    
    
}
