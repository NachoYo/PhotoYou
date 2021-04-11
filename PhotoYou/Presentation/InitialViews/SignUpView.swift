//
//  SignUpView.swift
//  PhotoYou
//
//  Created by Luis Ignacio Viñas Petriz on 10/04/21.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class SignUpView: UIViewController {
    //MARK:- Firebase Variables
    var getRef: Firestore!
    
    //MARK:- IBOutlets
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var lastNameTF: UITextField!
    @IBOutlet var firstNameTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI Specs
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Registrar Usuario"
        self.registerButton.layer.borderWidth = 2
        self.registerButton.layer.borderColor = UIColor.systemGreen.cgColor
        self.registerButton.layer.cornerRadius = 5
        let dismissGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(dismissGesture)
        self.getRef = Firestore.firestore()
    }
    
    //MARK:- Selector Functions
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    //MARK:- IBActions
    @IBAction func registerButtonAction(_ sender: UIButton) {
        guard let email = self.emailTF.text, email != "", let password = self.passwordTF.text, password != "", let name = self.firstNameTF.text, name != "", let lastname = self.lastNameTF.text, lastname != "" else{
            self.showMessage(message: "Falta algún dato")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error{
            print(error.localizedDescription)
                return
            }
            print("Usuario Creado", user?.user.uid)
            self.storeUser(uid: (user?.user.uid)!, name: name, lastname: lastname)
        }
    }
    
    //MARK:- Functions
    
    func showMessage(message: String){
        let alertController = UIAlertController(title: "Alerta", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController,animated: true)
    }
    
    func storeUser(uid: String, name: String, lastname: String){
        let emptyStringArray:[String] = []
        let data: [String: Any] = ["name": name, "lastname": lastname,"photosRef":emptyStringArray]
        
        getRef.collection("users").document(uid).setData(data, completion: { (error) in
            if error != nil{
                return
            }
            else{
                print("Datos Guardados")
            }
        })
        /*ref = getRef.collection("users").addDocument(data: data, completion: { (error) in
            if let error = error{
            self.showMessage(message: error.localizedDescription)
            return
        }else{
            //self.showMessage(message: "Datos Guardados")
            print("Datos Guardados")
            }
        })*/
    }

    
}
