//
//  YQCompletionQuestionV.swift
//  OpticalValleyUnite
//
//  Created by 杨庆 on 2018/6/27.
//  Copyright © 2018年 yangqing. All rights reserved.
//

import UIKit
import SnapKit

class YQCompletionQuestionV: UIView {
    
    //label
    var labelContent =  "" {
        
        didSet{
            
            let label = UILabel()
            
            if labelContent != "" {
                
                label.text = labelContent
            }
            
            label.numberOfLines = 0
            
            self.addSubview(label)
            
            let text = self.textFiledArray.last
            
            label.snp.makeConstraints { (maker) in
                
                if text != nil {//拼接动态
                    
                    maker.top.equalTo(text!.snp.bottom)
                    
                }else{//第一个
                    
                    maker.top.equalToSuperview().offset(15)
                }
                
                maker.left.equalToSuperview().offset(20)
                maker.right.equalToSuperview().offset(-20)
            }
            
            self.labelArray.append(label)
        }
        
    }
    
    //textView
    var textViewContent = "" {
        
        didSet{
            
            let textView = UITextView()
            
            if textViewContent != "" {
                
                textView.text = textViewContent
            }
            
            textView.backgroundColor = UIColor.init(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1.0)
            textView.isEditable = isEdit
            
            self.addSubview(textView)
            
            let label = self.labelArray.last
            
            textView.snp.makeConstraints { (marker) in
                
                if label != nil {
                    
                    marker.top.equalTo(label!.snp.bottom).offset(10)
                    
                }else{
                    
                    marker.top.equalToSuperview().offset(15)
                }
                
                marker.left.equalToSuperview().offset(20)
                marker.right.equalToSuperview().offset(-20)
                
                marker.height.equalTo(50)
                
            }
            
            self.textFiledArray.append(textView)
        }
    }
    

    var isEdit = true
    
    //text总数数组
    var textFiledArray = [UITextView]()
    
    //label总数数组
    var labelArray = [UILabel]()
    
    

}
