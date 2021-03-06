//
//  ReportListViewController.swift
//  OpticalValleyUnite
//
//  Created by 贺思佳 on 2017/5/27.
//  Copyright © 2017年 贺思佳. All rights reserved.
//

import UIKit
import SVProgressHUD
import MJRefresh

class ReportListViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    var currentDatas = [WorkOrderModel]()
    var pageNo = 0
    var selectButton : UIButton?
    
    @IBOutlet weak var waitingHandleButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //1.init
        self.navigationItem.title = "我的报事"
        self.waitingHandleButton.isSelected = true
        self.selectButton = waitingHandleButton
        addRefirsh()
        getWorkOrder()
        
        //2.注册cell
        let nib = UINib(nibName: "WorkOrder2Cell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100.0
    }
    
    // MARK: - typeButtonClick方法
    @IBAction func buttonSelectClick(_ sender: UIButton) {
        
        // 1 : 代表的是已关闭的 0 : 代表的是待处理的
        self.selectButton?.isSelected = false
        sender.isSelected = true
        self.selectButton = sender
        
        getWorkOrder( tag: sender.tag)
        
    }
    
    func addRefirsh(){
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            
            self.getWorkOrder(tag: (self.selectButton?.tag)!)
        })
        
        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            
            self.getWorkOrder(self.pageNo + 1,tag: (self.selectButton?.tag)!)
        })
    }

    
    func getWorkOrder(_ indexPage: Int = 0 , tag : Int = 0){
        
        var parmat = [String: Any]()
        parmat["pageIndex"] = indexPage
        parmat["isClosed"] = tag
        
        SVProgressHUD.show(withStatus: "加载中...")
        
        HttpClient.instance.get(path: URLPath.getReportList, parameters: parmat, success: { (response) in
            
            SVProgressHUD.dismiss()
            
            let data = response["data"] as? Array<[String: Any]>
            
            if (data?.isEmpty)! {
                
                SVProgressHUD.showError(withStatus: "没有更多数据!")
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.endRefreshing()
                return
            }

            var temp = [WorkOrderModel]()
            for dic in data! {
                
                let model = WorkOrderModel(parmart: dic)
                temp.append(model)
            }
            
            if indexPage == 0{
                self.pageNo = 0
                self.currentDatas = temp
                self.tableView.mj_header.endRefreshing()
            }else{
                
                if temp.count > 0{
                    self.pageNo = indexPage + 1
                    self.currentDatas.append(contentsOf: temp)
                    self.tableView.mj_footer.endRefreshing()
                }else{

                    self.tableView.mj_footer.endRefreshing()
                }
            }

            self.tableView.reloadData()
            
        }) { (error) in

            
        }
    }
}

extension ReportListViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: WorkOrder2Cell
        
        
        cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WorkOrder2Cell
        cell.model = currentDatas[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = WorkOrderProgressViewController.loadFromStoryboard(name: "WorkOrder") as! WorkOrderProgressViewController
        //        vc.workModelId = currentDatas[indexPath.row].workOrderId
        let model = currentDatas[indexPath.row]
        
        var parmat = [String: Any]()
        parmat["UNIT_STATUS"] = model.status
        parmat["PERSONTYPE"] = model.PERSONTYPE
        parmat["EXEC_PERSON_ID"] = model.execPersionId
        parmat["WORKUNIT_ID"] = model.workOrderId
        
        vc.parmate = parmat
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
