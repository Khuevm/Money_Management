//
//  TransactionCategoryVC.swift
//  Money Management
//
//  Created by Khue on 12/06/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class TransactionCategoryVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variable
    let db = Firestore.firestore()
    var user = Auth.auth().currentUser
    private var categories: [Category] = []
    private var categoriesByKind: [Category] = []
    
    weak var transactionFormDelegate: TransactionFormControllerDelegate!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configTableView()
        getAllCategory()
    }
    
    @IBAction func segmentValueChanged(_ sender: Any) {
        getCategoryByKind(kind: segment.selectedSegmentIndex)
    }
    
    // MARK: - Helper
    private func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryTableViewCell")
    }
    
    private func getAllCategory(){
        categories.removeAll()
        
        let email = user?.email
        let categoryListRef = db.collection("user")
            .document("\(email!)")
            .collection("category")
            .order(by: "id");
        categoryListRef.getDocuments { querySnapshot, error in
            if let err = error {
                print(err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    do {
                        let category = try document.data(as: Category.self)
                        self.categories.append(category)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
                self.getCategoryByKind(kind: self.segment.selectedSegmentIndex)
            }
        }

    }
    
    private func getCategoryByKind(kind: Int){
        categoriesByKind.removeAll()
        categoriesByKind = categories.filter(){
            $0.kind == kind
        }
        
        tableView.reloadData()
    }
}


// MARK: - UITableViewDelegate
extension TransactionCategoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        transactionFormDelegate.sendData(category: categoriesByKind[indexPath.row])
        
        self.dismiss(animated: true)
        print(categoriesByKind[indexPath.row])
    }
    
}

// MARK: - UITableViewDataSource
extension TransactionCategoryVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesByKind.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as! CategoryTableViewCell
        cell.setData(category: categoriesByKind[indexPath.row])
        return cell
    }
    
}
