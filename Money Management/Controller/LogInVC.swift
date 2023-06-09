//
//  LogInVC.swift
//  Money Management
//
//  Created by Khue on 23/05/2023.
//

import Foundation
import UIKit
import FirebaseAuth

class LogInVC: UIViewController {
    // MARK: - IBOutlet
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func config(){
        spinner.isHidden = true
        logoImageView.layer.cornerRadius = 30
        
        let logInAttributedString = NSMutableAttributedString(string: "Login")
        logInAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .bold), range: NSRange(location: 0, length: logInAttributedString.length))
        logInButton.setAttributedTitle(logInAttributedString, for: .normal)
        
        let signUpAttributedString = NSMutableAttributedString(string: "Sign Up")
        signUpAttributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16, weight: .semibold), range: NSRange(location: 0, length: signUpAttributedString.length))
        signUpButton.setAttributedTitle(signUpAttributedString, for: .normal)
    }
    
    // MARK: - IBAction
    @IBAction func logInButtonDidTap(_ sender: Any) {
        spinner.isHidden = false
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) {authResult, error in
                self.spinner.isHidden = true
                
                if let e = error {
                    //description bằng ngôn ngữ của user
                    let description = e.localizedDescription
                    self.showAlertError(error: description)
                } else {
                    //đăng nhập thành công
                    self.goToMainView()
                }
            }
            
        }
    }
    
    @IBAction func signUpButtonDidTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let resultVC = storyboard.instantiateViewController(identifier: "SignUp") as SignUpVC
        
        resultVC.modalPresentationStyle = .fullScreen
        self.present(resultVC, animated: false, completion: nil)
    }
    
    // MARK: - Helper
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
extension LogInVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //dismiss keyboard
        textField.resignFirstResponder()
        return true
    }
}
