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
    private var transactionsByDate = [String : [Transaction]]()
    private var transactionsDate: [Date] = []
    private let dateFormatter = DateFormatter()
    private var lastIndex = -1
    private var expense = 0, income = 0
    
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
        
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
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
                    resultVC.index = self.lastIndex + 1
                    
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
        
        transactionListRef.addSnapshotListener { [self] querySnapshot, error in
            self.user = Auth.auth().currentUser
            if self.user != nil, let snapshot = querySnapshot {
                expense = 0
                income = 0
                self.transactionsByDate.removeAll()
                self.transactionsDate.removeAll()
                snapshot.documents.forEach { document in
                    do {
                        let transaction = try document.data(as: Transaction.self)
                        let transactionDate = transaction.date.dateValue()
                        
                        lastIndex = transaction.id
                        
                        //calculate expense income
                        if transaction.category.kind == 0 {
                            expense += transaction.amount
                        } else {
                            income += transaction.amount
                        }
                        
                        //add date if not visible
                        if self.transactionsDate.first(where: {
                            self.isDateEqual($0, transactionDate)
                        }) == nil {
                            transactionsDate.append(transactionDate)
                            transactionsByDate[dateFormatter.string(from: transactionDate)] = []
                        }
                        transactionsByDate[dateFormatter.string(from: transactionDate)]!.append(transaction)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
                transactionsDate.sort()
                self.tableView.reloadData()
                reloadAmountLabel()
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
    
    private func isDateEqual(_ date1: Date, _ date2: Date) -> Bool {
        return dateFormatter.string(from: date1) == dateFormatter.string(from: date2)
    }
    
    private func reloadAmountLabel(){
        expenseLabel.text = "-\(expense)"
        incomeLabel.text = "+\(income)"
    }
}

extension HomeVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentTransactionDate = transactionsDate[indexPath.section]
        let strDate = dateFormatter.string(from: currentTransactionDate)
        
        let storyboard = UIStoryboard(name: "TransactionForm", bundle: nil)
        let resultVC = storyboard.instantiateViewController(identifier: "TransactionForm") as TransactionFormVC
        resultVC.setUpdateData(selectedTransaction: transactionsByDate[strDate]![indexPath.row])
        
        resultVC.modalPresentationStyle = .fullScreen
        self.present(resultVC, animated: false, completion: nil)
    }
}

extension HomeVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let currentTransactionDate = transactionsDate[section]
        return dateFormatter.string(from: currentTransactionDate)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return transactionsDate.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentTransactionDate = transactionsDate[section]
        let strDate = dateFormatter.string(from: currentTransactionDate)
        
        return transactionsByDate[strDate]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionTableViewCell") as! TransactionTableViewCell
        
        let currentTransactionDate = transactionsDate[indexPath.section]
        let strDate = dateFormatter.string(from: currentTransactionDate)
        
        cell.setData(transaction: transactionsByDate[strDate]![indexPath.row])
        return cell
    }
    
}
