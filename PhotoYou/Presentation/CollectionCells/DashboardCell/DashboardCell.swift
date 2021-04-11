//
//  DashboardCell.swift
//  PhotoYou
//
//  Created by Luis Ignacio Viñas Petriz on 11/04/21.
//

import UIKit

class DashboardCell: UICollectionViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var photoImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.photoImageView.layer.borderWidth = 4
        self.photoImageView.layer.borderColor = UIColor.systemGreen.cgColor
        self.photoImageView.layer.cornerRadius = 5
    }
    func setupCell(imageURL:URL,title:String){
        let placeHolder = UIImage(named: "loadingImage")!
        self.photoImageView.sd_setImage(with: imageURL, placeholderImage: placeHolder)
        self.titleLabel.text = title
    }
}
