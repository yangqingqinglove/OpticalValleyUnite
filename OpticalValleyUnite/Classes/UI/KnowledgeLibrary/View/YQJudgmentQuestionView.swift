//
//  YQJudgmentQuestionView.swift
//  OpticalValleyUnite
//
//  Created by 杨庆 on 2018/6/26.
//  Copyright © 2018年 yangqing. All rights reserved.
//

import UIKit

class YQJudgmentQuestionView: UIView {

    @IBOutlet weak var judgmentButton1: UIButton!
    
    @IBOutlet weak var judgmentButton2: UIButton!
    
    
    var selectButtonArray = [UIButton]()
    
    var isEdit = true

    
    @IBAction func selectButtonClick(_ sender: UIButton) {
        
        
        
        if sender.tag == 0 {
            
            self.judgmentButton1.isSelected = true
            self.judgmentButton2.isSelected = false
        
        }else{
            
            self.judgmentButton1.isSelected = false
            self.judgmentButton2.isSelected = true
            
        }
        
    }
    
    override func awakeFromNib() {
        
        self.selectButtonArray = [self.judgmentButton1,self.judgmentButton2]
        
        for temp in self.selectButtonArray{
            
            temp.isUserInteractionEnabled = self.isEdit
            
        }
    }
    
    
}