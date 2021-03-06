//
//  YQExecScanCell.swift
//  OpticalValleyUnite
//
//  Created by 杨庆 on 2017/11/30.
//  Copyright © 2017年 yangqing. All rights reserved.
//

import UIKit
import RealmSwift


protocol YQExecScanCellDelegate : class {
    
    func ExecScanCellScanButtonClick(indexPath : Int)
}

class YQExecScanCell: UITableViewCell {
    
    /*
     跳入扫码的界面: 回调,显示
     */
    @IBOutlet weak var scanButton: UIButton!
    
    @IBOutlet weak var scanLabel: UILabel!
    
    @IBOutlet weak var indexLabel: UILabel!
    
    
    weak var delegate : YQExecScanCellDelegate?
    
    var indexPath : Int?{
        
        didSet{
            
//            self.indexLabel.text = "\(indexPath)"
        }
        
    }
    
    //工单id
    var id : String!
    
    var backDB : Bool = false
    
    //数据模型
    var model : ExecChild?{
        didSet{
            
            self.indexLabel.text = model?.name
            
            if model?.value == "" {
            
                self.scanLabel.text = "请扫码核对工单信息"
            
            }else {
                
                if (model?.value.contains("未匹配"))!{
                    
                    self.scanLabel.textColor = UIColor.red
                    
                    
                }else if (model?.value.contains("已匹配"))!{
                    
                    self.scanLabel.textColor = UIColor.green
                }
                
                self.scanLabel.text = model?.value

            }
        }
    }

    

    @IBAction func scanButtonClick(_ sender: Any) {
        
        self.delegate?.ExecScanCellScanButtonClick(indexPath : indexPath!)
        
    }
    
    var color : String?{
        
        didSet{
            
            switch color! {
                
            case "red":
                self.scanLabel.text = "未匹配对应的设备"
                self.scanLabel.textColor = UIColor.red
                
                break
                
            case "green":
                self.scanLabel.text = "工单设备已匹配"
                self.scanLabel.textColor = UIColor.green
                
                break
                
            default:
                break
            }
        }
    }

   
}
