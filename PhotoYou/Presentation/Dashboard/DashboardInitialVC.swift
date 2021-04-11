//
//  DashboardInitialVC.swift
//  PhotoYou
//
//  Created by Luis Ignacio Viñas Petriz on 10/04/21.
//

import Foundation
import UIKit
import Firebase

protocol DashboardInicialDelegate {
    func reloadCollectionView()
}
extension DashboardInitialVC:DashboardInicialDelegate{
    func reloadCollectionView() {
        self.getPhotos()
    }
}
class DashboardInitialVC: UIViewController {
    var userID: String!
    var photosReferences:[String] = []
    var getRef: Firestore!
    
    var photosCells:[UICollectionViewCell] = []
    
    @IBOutlet var mainCollectionView: UICollectionView!
    @IBOutlet var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getRef = Firestore.firestore()
        
        self.title = "Fotos"
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        let bckBtn = UIBarButtonItem(title: "Cerrar Sesión", style: .done, target: self, action: #selector(self.logout))
        self.navigationItem.leftBarButtonItem = bckBtn
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        let uploadBtn = UIBarButtonItem(title: "Ver Perfil", style: .done, target: self, action: #selector(self.profileAcces))
        self.navigationItem.rightBarButtonItem = uploadBtn
        
        self.uploadButton.layer.borderWidth = 2
        self.uploadButton.layer.borderColor = UIColor.systemGreen.cgColor
        self.uploadButton.layer.cornerRadius = 5
        
        self.mainCollectionView.register(UINib(nibName: "DashboardCell", bundle: nil), forCellWithReuseIdentifier: "DashboardCell")
        
        self.mainCollectionView.delegate = self
        self.mainCollectionView.dataSource = self
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.scrollDirection = .vertical
        flowlayout.minimumInteritemSpacing = 0
        flowlayout.minimumLineSpacing = 0
        self.mainCollectionView.collectionViewLayout = flowlayout
        self.mainCollectionView.isPagingEnabled = true
        self.mainCollectionView.reloadData()
        
        self.getPhotos()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
//        self.getPhotos()
    }
    @objc func logout(){
        _ = try! Auth.auth().signOut()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func profileAcces(){
        let profileVC:UploadPhotoVC = UploadPhotoVC(type: .profilePhoto, userIDString: self.userID,photosStringArray: self.photosReferences, dashboardDel: self)
        profileVC.isModalInPresentation = true
        self.present(profileVC, animated: true, completion: nil)
    }
    
    func getPhotos(){
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil{
                print("Usuario no loggeado")
            }else{
                self.userID = user?.uid
                print(self.userID)
                self.getPhotosReferences()
            }
        }
    }
    
    func getPhotosReferences(){
        let result = getRef.collection("users").document(userID)
        result.getDocument { (snapshot, error) in
            
            let photos = snapshot?.get("photosRef") as? [String] ?? []
            self.photosReferences = photos
            
            if self.photosReferences.count > 0{
                for i in 0...self.photosReferences.count - 1{
                    let cell = self.mainCollectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCell", for: IndexPath(item: i, section: 0))
                    self.photosCells.append(cell)
                    self.getPhotoURL(photoReference: self.photosReferences[i], cellReference: i)
                }
                self.mainCollectionView.reloadData()
            }
        }
    }
    
    func getPhotoURL(photoReference:String,cellReference:Int){
        
        let storageReference = Storage.storage().reference()
        
        let userImageRef = storageReference.child("/usersPhotos").child(self.userID).child(photoReference)
            
        userImageRef.downloadURL { (url, error) in
            if let error = error{
                print("Error!: ",error.localizedDescription)
            }else{
                print("Imagen Descargada")
                print(url)
                (self.photosCells[cellReference] as! DashboardCell).setupCell(imageURL: url!, title: photoReference)
            }
        }
        
    }
    
    @IBAction func uploadButtonAction(_ sender: UIButton) {
        let uploadVC:UploadPhotoVC = UploadPhotoVC(type: .newPhoto, userIDString: self.userID,photosStringArray: self.photosReferences, dashboardDel: self)
        uploadVC.isModalInPresentation = true
        self.present(uploadVC, animated: true, completion: nil)
    }
    
    
}

extension DashboardInitialVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosReferences.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return self.photosCells[indexPath.item]
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 2, height: 300)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC:PhotoDetailView = PhotoDetailView(image: (self.photosCells[indexPath.item] as! DashboardCell).photoImageView.image!, desc: self.photosReferences[indexPath.item], userUID: self.userID)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}
