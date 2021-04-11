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

class UploadPhotoVC: UIViewController, UINavigationControllerDelegate {
    var userID: String
    var getRef: Firestore!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var imagePreview: UIImageView!
    
    @IBOutlet var photoDescTF: UITextField!
    
    var optimizedImage: Data!
    var stringsArray:[String]
    var dashboardDelegate:DashboardInicialDelegate!
    init(userIDString:String,photosStringArray:[String],dashboardDel:DashboardInicialDelegate) {
        self.dashboardDelegate = dashboardDel
        self.userID = userIDString
        self.stringsArray = photosStringArray
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.userID = ""
        self.stringsArray = []
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
                        print("Error: ",error.localizedDescription)
                    }else{
                        print("Éxito ",storageMetaData?.path)
                        
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
            if  self.photoDescTF.text!.count > 0{
                self.enableUploadPhotoButton()
            }
            else{
                self.disableUploadPhotoButton()
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
