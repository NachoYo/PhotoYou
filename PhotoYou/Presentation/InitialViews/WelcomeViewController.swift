//
//  WelcomeViewController.swift
//  PhotoYou
//
//  Created by Luis Ignacio Viñas Petriz on 10/04/21.
//

import Foundation
import UIKit
import Firebase

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.isUserLogged()
    }
    
    func isUserLogged(){
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil{
                print("Usuario no loggeado")
                self.performSegue(withIdentifier: "notLoggedUserSegue", sender: self)
                return
            }else{
                print("Usuario Loggeado")
                self.performSegue(withIdentifier: "welcomeView", sender: self)
            }
        }
    }

}
