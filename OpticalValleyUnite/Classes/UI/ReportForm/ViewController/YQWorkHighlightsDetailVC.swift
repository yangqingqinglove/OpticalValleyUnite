//
//  YQWorkHighlightsDetailVC.swift
//  OpticalValleyUnite
//
//  Created by 杨庆 on 2018/1/19.
//  Copyright © 2018年 yangqing. All rights reserved.
//

import UIKit
import MJRefresh
import SVProgressHUD

class YQWorkHighlightsDetailVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataArray = [YQWorkHighlightsDetailShowModel](){
        
        didSet{
            
            self.tableView.reloadData()
        }
        
    }
    
    //行高缓存
    var heightDict = [String : Any]()
    
    var cellID = "WorkHighlightsDetailCell"
    
    var parkID = ""
    var currentIndex = 0
    
    var create = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "工作亮点"
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        let _ = setUpProjectNameLable()
        
        addRefirsh()
        
        getDataForService()
        
    }
    
    
    func getDataForService(pageIndex : Int = 0 ){
        
        var par = [String : Any]()
        par["pageIndex"] = pageIndex
        par["pageSize"] = 20
        par["reportId"] = 3 //只有月报的主键
        par["parkId"] = self.parkID
        par["create"] = self.create
        
        SVProgressHUD.show()
        
        HttpClient.instance.post(path: URLPath.getReportWorkHighlights, parameters: par, success: { (response) in
            SVProgressHUD.dismiss()
            
            let array = response["data"] as? Array<[String : Any]>
            
//            if (array?.isEmpty)! {
//                
//                self.dataArray.removeAll()
//                self.tableView.mj_header.endRefreshing()
//                self.tableView.mj_footer.endRefreshing()
//
//                SVProgressHUD.showError(withStatus: "没有加载更多的数据!")
//                return
//            }
            
            var tempDataArray = [YQWorkHighlightsDetailShowModel]()
            
            for temp in array! {
                
                tempDataArray.append(YQWorkHighlightsDetailShowModel.init(dict: temp))
            }
            
            
            //添加上拉下拉刷新的情况
            if pageIndex == 0 {
                
                if array == nil {
                    
                    self.dataArray.removeAll()
                    self.tableView.mj_header.endRefreshing()
                    self.tableView.mj_footer.endRefreshing()
                    
                    return
                }

                self.dataArray = tempDataArray
                
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()

            }else{
                
                if tempDataArray.count > 0{
                    
                    self.currentIndex = pageIndex
                    
                    self.dataArray.append(contentsOf: tempDataArray)
                    
                }
                
                self.tableView.mj_footer.endRefreshing()
                
            }
            
        }) { (error) in
            
            SVProgressHUD.showError(withStatus: "网络连接失败")
        }
    }
    
    // MARK: - 上下拉的刷新的界面情况
    func addRefirsh(){
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
    
            self.getDataForService()
            
        })
        
        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            
            self.getDataForService(pageIndex: self.currentIndex + 1)
            
        })
        
    }

    
    // MARK: - 添加默认的项目选择方法
    func setUpProjectNameLable() -> String{
        
        let dic = UserDefaults.standard.object(forKey: Const.YQProjectModel) as? [String : Any]
        
        var projectName  = ""
        
        if dic != nil {
            
            projectName = dic?["PARK_NAME"] as! String
            self.parkID = dic?["ID"] as! String
            
        }else{
            
            projectName = "请选择默认项目"
        }
        
        return projectName
    }


}

extension YQWorkHighlightsDetailVC : UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? YQWorkHighlightsDetailCell
        
        if cell == nil {
            
            //注册原型cell 设置cell的每个的行高的情况
            cell = Bundle.main.loadNibNamed("YQWorkHighlightsDetailCell", owner: nil, options: nil)?[0] as? YQWorkHighlightsDetailCell
            
        }
        
        cell?.indexPath = indexPath
        cell?.model = self.dataArray[indexPath.row]
        
        //强制更新
        cell?.layoutIfNeeded()
        
        //要求的定义的是 一个可变的字典的类型的来赋值
        heightDict["\(indexPath.row)"] = cell?.cellForHeight()
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return heightDict["\(indexPath.row)"] as! CGFloat
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 350
    }

}
