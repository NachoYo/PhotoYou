//
//  LoginViewController.swift
//  PhotoYou
//
//  Created by Luis Ignacio Viñas Petriz on 10/04/21.
//

import Foundation
import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var signUpButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        self.loginButton.layer.borderWidth = 2
        self.loginButton.layer.borderColor = UIColor.systemGreen.cgColor
        self.loginButton.layer.cornerRadius = 5
        
        self.signUpButton.layer.borderWidth = 2
        self.signUpButton.layer.borderColor = UIColor.systemGreen.cgColor
        self.signUpButton.layer.cornerRadius = 5
    }

    @IBAction func loginAction(_ sender: Any) {
        self.performSegue(withIdentifier: "signInSegue", sender: self)
    }
    @IBAction func signUpAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signUpSegue", sender: self)
    }
}
