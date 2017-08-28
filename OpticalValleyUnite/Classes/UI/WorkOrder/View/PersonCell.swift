//
//  PersonCell.swift
//  OpticalValleyUnite
//
//  Created by 贺思佳 on 2017/2/20.
//  Copyright © 2017年 贺思佳. All rights reserved.
//

import UIKit
import Kingfisher

class PersonCell: UITableViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var selectedBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var model: PersonModel?{
        didSet{
            if let model = model {
                nameLabel.text = model.name
                
                if let url = URL(string: model.icon) {
                    iconView.kf.setImage(with: url)
                }else{
                    iconView.image = UIImage(named: "avatar")
                }
                selectedBtn.isSelected = model.selected
                
            }
        }
    }

}
