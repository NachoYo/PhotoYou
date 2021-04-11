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
    init(image:UIImage,desc:String,userUID:String) {
        self.userID = userUID
        self.imageDescription = desc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.userID = ""
        self.imageDescription = ""
        super.init(nibName: nil, bundle: nil)
//        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let storageReference = Storage.storage().reference()
        let forestRef = storageReference.child("/usersPhotos").child(self.userID).child(self.imageDescription)

        // Get metadata properties
        forestRef.getMetadata { metadata, error in
          if let error = error {
            // Uh-oh, an error occurred!
            print("error")
          } else {
            // Metadata now contains the metadata for 'images/forest.jpg'
            print("Exito",metadata)
          }
        }
    }

}
