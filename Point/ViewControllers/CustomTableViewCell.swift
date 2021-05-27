//
//  CustomTableViewCell.swift
//  Point
//
//  Created by Zaoksky on 11.04.2021.
//

import UIKit
import Cosmos // [26]

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 5
            imageOfPlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView! {
        didSet {
                // [26] Отключим возможность менять кол-во звезд на главном экране
            cosmosView.settings.updateOnTouch = false
        }
    }
    
    deinit {
        print("deinit", CustomTableViewCell.self)
    }
    
}
