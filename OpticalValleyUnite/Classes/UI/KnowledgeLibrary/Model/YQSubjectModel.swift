//
//  YQSubjectModel.swift
//  OpticalValleyUnite
//
//  Created by 杨庆 on 2018/7/2.
//  Copyright © 2018年 yangqing. All rights reserved.
//

import UIKit

class YQSubjectModel: NSObject {
    
    //题目id
    var id : Int64 = -1
    
    //题目类型. 1单选 2多选 3判断 4填空 5问答
    var type = -1
    
    //题干
    var question = ""
    
    //图片，多个逗号分隔
    var images = ""
    
    //考生选的答案，多个用$区分
    var choose = ""
    
    //已考的新增的数据模型
    //已考的答案试题
    var score = -1
    
    //是否答对 0为未答对 1答对
    var isRight = -1
    
    //正确答案
    var answer = ""
    
    
    //题目下面的选项内容
    var optionDetail = Array<[String : Any]>()
    
    //该考试是否结束 0未结束 1结束
    //var isEnd : Int64 = -1
    
    init(dict : [String : Any]) {
        
        super.init()
        
        setValuesForKeys(dict)
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
}
