//
//  YQJoinExamCell.swift
//  OpticalValleyUnite
//
//  Created by 杨庆 on 2018/6/21.
//  Copyright © 2018年 yangqing. All rights reserved.
//

import UIKit

class YQJoinExamCell: UITableViewCell {

    @IBOutlet weak var examTilteLabel: UILabel!
    
    @IBOutlet weak var alreadyLabel: UILabel!
    
    @IBOutlet weak var joinExamScoreLabel: UILabel!
    
    @IBOutlet weak var examTimeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    
    }

    
    var model : YQExamOwnListModel?{
        
        didSet{
            
            self.examTilteLabel.text = model?.name
            self.joinExamScoreLabel.text = "考试分数  " + "\(model?.totalScore ?? 0)"
            self.examTimeLabel.text = "考试时间  " + (model?.time)!
            
            //判断是否 参加
            if model?.isAttend == 1{
                
                self.alreadyLabel.isHidden = false
                
            }
            
            
        }
        
    }
  
    
}
