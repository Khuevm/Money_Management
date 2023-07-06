//
//  HomeVC.swift
//  Money Management
//
//  Created by Khue on 23/05/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var incomeLabel: UILabel!
    
    // MARK: - Variable
    private let db = Firestore.firestore()
    private var user = Auth.auth().currentUser
    private var transactions: [Transaction] = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton.setTitle("", for: .normal)
        logOutButton.setTitle("", for: .normal)
        
        //welcomeLabel
        let email = user?.email
        
        db.collection("user").document("\(email!)").getDocument(as: User.self) { result in
            switch result {
                case .success(let user):
                
                    self.welcomeLabel.text = "Welcome \(user.name)"
                case .failure(let error):
                    self.showAlertError(error: error.localizedDescription)
                }
        }
        
        configTableView()
        getAllTransaction()
    }
    
    // MARK: - IBAction
    @IBAction func logOutButtonDidTap(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            goToLoginView()
        } catch let signOutError as NSError {
            showAlertError(error: signOutError.localizedDescription)
        }
    }
    
    @IBAction func addButtonDidTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TransactionForm", bundle: nil)
        let resultVC = storyboard.instantiateViewController(identifier: "TransactionForm") as TransactionFormVC
        resultVC.modalPresentationStyle = .fullScreen
        
        //Get first category
        let email = user?.email
        let categoryListRef = db.collection("user")
            .document("\(email!)")
            .collection("category")
            .order(by: "id")
            .limit(to: 1);

        categoryListRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                self.showAlertError(error: err.localizedDescription)
            } else {
                let categoryList = querySnapshot!.documents
                if categoryList.count > 0 {
                    let firstCategory = try? categoryList[0].data(as: Category.self)
                    resultVC.selectedCategory = firstCategory!
                    resultVC.index = (self.transactions.last?.id ?? -1) + 1
                    
                    self.present(resultVC, animated: false, completion: nil)
                } else {
                    self.showAlertError(error: "You need to have category")
                }
            }
        }
    }
    
    // MARK: - Firebase
    private func getAllTransaction(){
        let email = user?.email
        let transactionListRef = db.collection("user")
            .document("\(email!)")
            .collection("transaction")
            .order(by: "id");
        transactionListRef.addSnapshotListener { querySnapshot, error in
            self.user = Auth.auth().currentUser
            if self.user != nil, let snapshot = querySnapshot {
                self.transactions.removeAll()
                snapshot.documents.forEach { document in
                    do {
                        let transaction = try document.data(as: Transaction.self)
                        self.transactions.append(transaction)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
                self.tableView.reloadData()
            }
        }

    }
    
    // MARK: - Helper
    private func configTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionTableViewCell")
    }
    
    private func showAlertError(error: String){
        let alertController = UIAlertController.init(title: "Error", message: error, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Try Again", style: .cancel)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
    
    private func goToLoginView(){
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        let resultVC = storyboard.instantiateViewController(identifier: "LogIn") as LogInVC
        
        resultVC.modalPresentationStyle = .fullScreen
        self.present(resultVC, animated: false, completion: nil)
    }
}

extension HomeVC: UITableViewDelegate {
    
}

extension HomeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
        cell.setData(transaction: transactions[indexPath.row])
        return cell
    }
    
}
