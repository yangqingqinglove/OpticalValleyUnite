//
//  YQJournalDetailTVCell.swift
//  OpticalValleyUnite
//
//  Created by 杨庆 on 2017/10/30.
//  Copyright © 2017年 yangqing. All rights reserved.
//

import UIKit

class YQJournalDetailTVCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!


    // MARK: - 返回非等高cell的height方法
    func cellForHeight() -> CGFloat {
        // detailLabel.frame.maxY + detailLabel.frame.width + 10
        
        return contentLabel.frame.maxY + 25
        
    }

    
    
}
