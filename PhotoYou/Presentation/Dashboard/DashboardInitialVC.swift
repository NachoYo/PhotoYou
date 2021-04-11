//
//  DashboardInitialVC.swift
//  PhotoYou
//
//  Created by Luis Ignacio Viñas Petriz on 10/04/21.
//

import Foundation
import UIKit
import Firebase

class DashboardInitialVC: UIViewController {
    var userID: String!
    var photosReferences:[String] = []
    var getRef: Firestore!
    
    var photosCells:[UICollectionViewCell] = []
    
    @IBOutlet var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getRef = Firestore.firestore()
    
        self.navigationItem.setHidesBackButton(true, animated: true)
        let bckBtn = UIBarButtonItem(title: "Cerrar Sesión", style: .done, target: self, action: #selector(self.logout))
        self.navigationItem.leftBarButtonItem = bckBtn
        
        self.navigationItem.setHidesBackButton(true, animated: true)
        let uploadBtn = UIBarButtonItem(title: "Subir Foto", style: .done, target: self, action: #selector(self.registerPhoto))
        self.navigationItem.rightBarButtonItem = uploadBtn
        self.getPhotos()
        
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
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    @objc func logout(){
        _ = try! Auth.auth().signOut()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func registerPhoto(){
        self.getData(uid: self.userID)
    }
    
    func getPhotos(){
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil{
                print("Usuario no loggeado")
            }else{
//                self.emailLabel.text = user?.email
                self.userID = user?.uid
//                self.getName()
                print(self.userID)
                self.getPhoto()
            }
        }
    }
    func getPhoto(){
        var result = getRef.collection("users").document(userID)
        result.getDocument { (snapshot, error) in
            
            let photos = snapshot?.get("photosRef") as? [String] ?? []
            self.photosReferences = photos
            
            for i in 0...self.photosReferences.count - 1{
                let cell = self.mainCollectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCell", for: IndexPath(item: i, section: 0))
                self.photosCells.append(cell)
            }
            self.mainCollectionView.reloadData()
//            let name = snapshot?.get("name") as? String ?? "sin valor"
//            let lastname = snapshot?.get("lastname") as? String ?? "sin valor"
//            self.nameLabel.text = name + " " + lastname
        }
    }
    
    func getData(uid: String){
        var stringArray:[String] = self.photosReferences
        stringArray.append("Photo_Mas")
        let data: [String: Any] = ["photosRef":stringArray]
        getRef.collection("users").document(uid).setData(data, mergeFields: ["photosRef"]) { (error) in
            if error != nil{
                return
            }
            else{
                print("Datos Guardados")
            }
        }
//        getRef.collection("users").document(uid).setData(data, completion: { (error) in

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
}
