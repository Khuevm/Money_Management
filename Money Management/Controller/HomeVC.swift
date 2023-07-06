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
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser
    var transactions: [Transaction] = []
    
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
        self.present(resultVC, animated: false, completion: nil)
    }
    
    // MARK: - Helper
    private func configTableView(){
        let transaction1 = Transaction(id: 0, category: Category(id: 0, name: "Cate 1", kind: 0, imageColor: "#F8B858", categoryImageId: 3), amount: 20000, date: Timestamp(date: Date()), note: "")
        let transaction2 = Transaction(id: 1, category: Category(id: 0, name: "Cate 2", kind: 1, imageColor: "#c078d8", categoryImageId: 5), amount: 50000, date: Timestamp(date: Date()), note: "hihi")
        
        transactions.append(transaction1)
        transactions.append(transaction2)
        
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
