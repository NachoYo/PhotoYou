//
//  SignInView.swift
//  PhotoYou
//
//  Created by Luis Ignacio Viñas Petriz on 10/04/21.
//

import Foundation
import UIKit
import Firebase

class SignInView: UIViewController {

    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Iniciar Sesión"
        
        self.loginButton.layer.borderWidth = 2
        self.loginButton.layer.borderColor = UIColor.systemGreen.cgColor
        self.loginButton.layer.cornerRadius = 5
        
        let dismissGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(dismissGesture)
    }
    
    //MARK:- Selector Functions
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    //MARK:- IBActions
    @IBAction func loginButtonAction(_ sender: Any) {
        guard let email = emailTF.text, email != "", let password = passwordTF.text, password != "" else{
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error{
                print(error.localizedDescription)
                return
            } else{
                print("Usuario Autenticado")
                /*
                let welcomeView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "welcomeViewController") as? WelcomeViewController
                self.dismiss(animated: true) {
                self.navigationController?.pushViewController(welcomeView!, animated: true)
                }
                */
                //self.present(welcomeView!,animated:true,completion: nil)
            }
        }
    }
}
