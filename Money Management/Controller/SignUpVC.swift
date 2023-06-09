//
//  SignUpVC.swift
//  Money Management
//
//  Created by Khue on 24/05/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class SignUpVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
    }
    
    func config(){
        spinner.isHidden = true
        logoImageView.layer.cornerRadius = 30
        
        let signUpAttributedString = NSMutableAttributedString(string: "Sign Up")
        signUpAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: NSRange(location: 0, length: signUpAttributedString.length))
        signUpButton.setAttributedTitle(signUpAttributedString, for: .normal)
        
        let logInAttributedString = NSMutableAttributedString(string: "Login")
        logInAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .semibold), range: NSRange(location: 0, length: logInAttributedString.length))
        logInButton.setAttributedTitle(logInAttributedString, for: .normal)
    }
    
    
    // MARK: - IBAction
    @IBAction func signUpButtonDidTap(_ sender: Any) {
        spinner.isHidden = false
        
        if let name = nameTextField.text,
           let email = emailTextField.text,
           let password = passwordTextField.text,
           let confirmPassword = confirmPasswordTextField.text {
            
            if (name.trimmingCharacters(in: .whitespacesAndNewlines) == "") {
                self.spinner.isHidden = true
                
                self.showAlertError(error: "Missing information")
                return
            }
            
            if (password != confirmPassword) {
                self.spinner.isHidden = true
                
                self.showAlertError(error: "Password does not match")
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) {authResult, error in
                self.spinner.isHidden = true
                
                if error != nil {
                    //description bằng ngôn ngữ của user
                    self.showAlertError(error: error!.localizedDescription)
                } else {
                    //đăng ký thành công
                    let user = User(name: name, email: email)
                    do {
                        try Firestore.firestore()
                            .collection("user")
                            .document(email)
                            .setData(from: user) { error in
                                if error == nil {
                                    self.addDefaultCate(user: user)
                                    self.goToMainView()
                                } else {
                                    self.showAlertError(error: error!.localizedDescription)
                                }
                            }
                    } catch let error {
                        self.showAlertError(error: error.localizedDescription)
                    }
                    
                    self.goToMainView()
                }
            }
            
        }
    }
    
    @IBAction func logInButtonDidTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LogIn", bundle: nil)
        let resultVC = storyboard.instantiateViewController(identifier: "LogIn") as LogInVC
        
        resultVC.modalPresentationStyle = .fullScreen
        self.present(resultVC, animated: false, completion: nil)
    }
    
    // MARK: - Helper
    func addDefaultCate(user: User) {
        for i in 0..<K.cateName.count {
            let categoryName = K.cateName[i]
            let categoryImageId = K.imageId[i]
            let categoryImageColor = K.imageColor[i]
            let categoryKind = K.kind[i]
            
            let category = Category(id: i, name: categoryName, kind: categoryKind, imageColor: categoryImageColor, categoryImageId: categoryImageId)
            do {
                try Firestore.firestore()
                    .collection("user")
                    .document(user.email)
                    .collection("category")
                    .document("\(i)")
                    .setData(from: category)
            } catch let error {
                self.showAlertError(error: error.localizedDescription)
            }
        }
    }
    
    func showAlertError(error: String){
        let alertController = UIAlertController.init(title: "Error", message: error, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "Try Again", style: .cancel)
        alertController.addAction(action)
        self.present(alertController, animated: true)
    }
    
    func goToMainView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewController(identifier: "Main") as MainVC
        
        resultVC.modalPresentationStyle = .fullScreen
        self.present(resultVC, animated: false, completion: nil)
    }
}


// MARK: - UITextFieldDelegate
extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //dismiss keyboard
        textField.resignFirstResponder()
        return true
    }
}

