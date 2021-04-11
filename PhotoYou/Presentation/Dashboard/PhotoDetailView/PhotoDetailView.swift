//
//  PhotoDetailView.swift
//  PhotoYou
//
//  Created by Luis Ignacio Viñas Petriz on 11/04/21.
//

import UIKit
import Firebase

class PhotoDetailView: UIViewController {
    @IBOutlet var detailImageView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    let userID:String
    let imageDescription:String
    let imageDetail:UIImage
    init(image:UIImage,desc:String,userUID:String) {
        self.userID = userUID
        self.imageDetail = image
        self.imageDescription = desc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.userID = ""
        self.imageDescription = ""
        self.imageDetail = UIImage()
        
        super.init(nibName: nil, bundle: nil)
//        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let storageReference = Storage.storage().reference()
        let imageRef = storageReference.child("/usersPhotos").child(self.userID).child(self.imageDescription)
        // Get metadata properties
        imageRef.getMetadata { metadata, error in
          if let error = error {
            // Uh-oh, an error occurred!
            print("error")
          } else {
            // Metadata now contains the metadata for 'images/forest.jpg'
            let formater:DateFormatter = DateFormatter()
            formater.dateFormat = "dd/MM/yyyy"
            
            self.dateLabel.text = formater.string(from: metadata!.timeCreated!)
          }
        }
        
        self.descriptionLabel.text = self.imageDescription
        
        let originalFrame:CGRect = self.detailImageView.bounds
        self.detailImageView.image = self.imageDetail
        self.detailImageView.bounds = originalFrame
        
        self.detailImageView.layer.borderWidth = 2
        self.detailImageView.layer.borderColor = UIColor.systemGreen.cgColor
        self.detailImageView.layer.cornerRadius = 5

    }

}
