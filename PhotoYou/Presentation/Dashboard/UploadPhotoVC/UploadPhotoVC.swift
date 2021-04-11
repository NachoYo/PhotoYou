//
//  UploadPhotoVC.swift
//  PhotoYou
//
//  Created by Luis Ignacio Viñas Petriz on 11/04/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import MobileCoreServices
import FirebaseUI

enum UploadPhotoCases{
    case newPhoto
    case profilePhoto
}

extension UploadPhotoVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.photoDescTF.resignFirstResponder()
        return false
    }
}

class UploadPhotoVC: UIViewController, UINavigationControllerDelegate {
    var userID: String
    var getRef: Firestore!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var imagePreview: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var photoDescTF: UITextField!
    
    var optimizedImage: Data!
    var stringsArray:[String]
    var dashboardDelegate:DashboardInicialDelegate!
    var typeOfView:UploadPhotoCases
    init(type:UploadPhotoCases,userIDString:String,photosStringArray:[String],dashboardDel:DashboardInicialDelegate) {
        self.typeOfView = type
        self.dashboardDelegate = dashboardDel
        self.userID = userIDString
        self.stringsArray = photosStringArray
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.userID = ""
        self.stringsArray = []
        self.typeOfView = .newPhoto
        super.init(nibName: nil, bundle: nil)
//        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getRef = Firestore.firestore()
        self.cancelButton.layer.borderWidth = 2
        self.cancelButton.layer.borderColor = UIColor.systemRed.cgColor
        self.cancelButton.layer.cornerRadius = 5
        
        self.searchButton.layer.borderWidth = 2
        self.searchButton.layer.borderColor = UIColor.systemGreen.cgColor
        self.searchButton.layer.cornerRadius = 5
        
        self.imagePreview.layer.borderWidth = 2
        self.imagePreview.layer.borderColor = UIColor.systemGreen.cgColor
        self.imagePreview.layer.cornerRadius = 5
        
        self.uploadButton.layer.borderWidth = 2
        self.uploadButton.layer.borderColor = UIColor.systemGray.cgColor
        self.uploadButton.layer.cornerRadius = 5
        self.uploadButton.backgroundColor = UIColor.systemGray6
        self.uploadButton.isUserInteractionEnabled = false
        
        switch self.typeOfView {
        case .newPhoto:
            self.photoDescTF.delegate = self
        break
        case .profilePhoto:
            self.photoDescTF.isHidden = true
            self.nameLabel.isHidden = false
            self.cancelButton.setTitle("Cerrar", for: .normal)
            self.loadUserName()
        }
        
        let dismissGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(dismissGesture)
    }
    
    //MARK:- Selector Functions
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func disableUploadPhotoButton(){
        self.uploadButton.layer.borderWidth = 2
        self.uploadButton.layer.borderColor = UIColor.systemGray.cgColor
        self.uploadButton.layer.cornerRadius = 5
        self.uploadButton.backgroundColor = UIColor.systemGray6
        self.uploadButton.setTitleColor(UIColor.systemGray, for: .normal)
        self.uploadButton.isUserInteractionEnabled = false
    }
    func enableUploadPhotoButton(){
        self.uploadButton.layer.borderWidth = 2
        self.uploadButton.layer.borderColor = UIColor.systemGreen.cgColor
        self.uploadButton.layer.cornerRadius = 5
        self.uploadButton.backgroundColor = UIColor.systemGreen
        self.uploadButton.isUserInteractionEnabled = true
        self.uploadButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func loadUserName(){
        
        let activityIndicator = UIActivityIndicatorView.init(style: .large)
        activityIndicator.color = .systemGreen
        activityIndicator.startAnimating()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        
        let result = getRef.collection("users").document(userID)
        result.getDocument { (snapshot, error) in
            let name = snapshot?.get("name") as? String ?? "sin valor"
            let lastname = snapshot?.get("lastname") as? String ?? "sin valor"
            self.nameLabel.text = name + " " + lastname
        }
        
        let storageReference = Storage.storage().reference()
        let placeHolder = UIImage(named: "noPhoto")
        let userImageRef = storageReference.child("/usersPhotos").child(self.userID).child("profilePhoto").child("profilePhoto")
        userImageRef.downloadURL { (url, error) in
            if let error = error{
                print("Error: ",error.localizedDescription)
                
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }else{
                print("Imagen Descargada")
                print(url)
                self.imagePreview.sd_setImage(with: url, placeholderImage: placeHolder)
                
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
        self.imagePreview.sd_setImage(with: userImageRef, placeholderImage: placeHolder)
        
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func searchPhotoAction(_ sender: Any) {
        let photoImage = UIImagePickerController()
        photoImage.sourceType = UIImagePickerController.SourceType.photoLibrary
        photoImage.mediaTypes = [kUTTypeImage as String]
        photoImage.delegate = self
        present(photoImage, animated: true)
    }
    @IBAction func uploadPhotoAction(_ sender: Any) {
        switch self.typeOfView {
        case .newPhoto:
            let contains:Bool = self.stringsArray.contains(self.photoDescTF.text!)
            if !contains{
                let activityIndicator = UIActivityIndicatorView.init(style: .large)
                activityIndicator.color = .red
                activityIndicator.startAnimating()
                activityIndicator.center = self.view.center
                self.view.addSubview(activityIndicator)
                
                let storageReference = Storage.storage().reference()
                let userImageRef = storageReference.child("/usersPhotos").child(self.userID).child(self.photoDescTF.text!)
                let uploadMetaData = StorageMetadata()
                
                uploadMetaData.contentType = "image/jpeg"
                
                if let imageToUpload = self.optimizedImage{
                    userImageRef.putData(imageToUpload, metadata: uploadMetaData) { (storageMetaData, error) in
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        if let error = error{
                            let alertController = UIAlertController(title: "Alerta", message: error.localizedDescription, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController,animated: true)
                        }else{
                            var stringArray:[String] = self.stringsArray
                            stringArray.append(self.photoDescTF.text!)
                            let data: [String: Any] = ["photosRef":stringArray]
                            self.getRef.collection("users").document(self.userID).setData(data, mergeFields: ["photosRef"]) { (error) in
                                if error != nil{
                                    return
                                }
                                else{
                                    print("Datos Guardados")
                                }
                            }
                            self.dashboardDelegate.reloadCollectionView()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
            else{
                let alertController = UIAlertController(title: "Alerta", message: "Ya tienes una foto con este título", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController,animated: true)
            }
        case .profilePhoto:
            let contains:Bool = self.stringsArray.contains(self.photoDescTF.text!)
            if !contains{
                let activityIndicator = UIActivityIndicatorView.init(style: .large)
                activityIndicator.color = .systemGreen
                activityIndicator.startAnimating()
                activityIndicator.center = self.view.center
                self.view.addSubview(activityIndicator)
                
                let storageReference = Storage.storage().reference()
                let userImageRef = storageReference.child("/usersPhotos").child(self.userID).child("profilePhoto").child("profilePhoto")
                let uploadMetaData = StorageMetadata()
                
                uploadMetaData.contentType = "image/jpeg"
                
                if let imageToUpload = self.optimizedImage{
                    userImageRef.putData(imageToUpload, metadata: uploadMetaData) { (storageMetaData, error) in
                        activityIndicator.stopAnimating()
                        activityIndicator.removeFromSuperview()
                        if let error = error{
                            print("Error: ",error.localizedDescription)
                        }else{
                            print("Éxito ",storageMetaData?.path)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                else{
                    let alertController = UIAlertController(title: "Alerta", message: "Ya tienes una foto con este título", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController,animated: true)
                }
            }
        }
    }
    
    @IBAction func changedDescTF(_ sender: Any) {
        if  self.photoDescTF.text!.count > 0 && self.optimizedImage != nil{
            self.enableUploadPhotoButton()
        }
        else{
            self.disableUploadPhotoButton()
        }
    }
    
}
extension UploadPhotoVC:UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let optimizedImageData = imageSelected.jpegData(compressionQuality: 0.3){
            self.optimizedImage = optimizedImageData
            self.imagePreview.image = imageSelected
//            self.saveImage(optimizedImageData)
            
            switch self.typeOfView {
            case .newPhoto:
                if  self.photoDescTF.text!.count > 0{
                    self.enableUploadPhotoButton()
                }
                else{
                    self.disableUploadPhotoButton()
                }
            case .profilePhoto:
                self.enableUploadPhotoButton()
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
