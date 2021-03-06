//
//  SurveillanceWorkOrderViewController.swift
//  OpticalValleyUnite
//
//  Created by 贺思佳 on 2017/1/11.
//  Copyright © 2017年 贺思佳. All rights reserved.
//

import UIKit
import SVProgressHUD
import MJRefresh

class SurveillanceWorkOrderViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var belowView: UIView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    //设置检索参数
    var pageNo = 0
    var startT = ""
    var endT   = ""
    var park_ID = ""
    
    @IBOutlet weak var didProcessedBtn: UIButton!
    @IBOutlet weak var waitProcessedBtn: UIButton!
    var currentStatusBtn: UIButton?
    var shouldReload = true
    var currentDatas = [WorkOrderModel](){
        didSet{
            tableView.reloadData()
        }
    }
    
    // MARK: - 视图生命周期的方法
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = 226.0
        tableView.allowsMultipleSelectionDuringEditing = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectionDidChange(noti:)), name: .UITableViewSelectionDidChange, object: self.tableView)
        
        statusBtnClick(waitProcessedBtn)

        addRefirsh()
        
        //添加设置park_id的默认情况
        park_ID = getUserDefaultsProject()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if shouldReload {
            
            getWorkOrder(type:(currentStatusBtn?.tag) ?? 0)
        }
        
    }
    
    // MARK: - dealloc的方法
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: .UITableViewSelectionDidChange, object: self.tableView)
        
        print("SurveillanceWorkOrderViewController----deinit")
       
    }
    
    
    // MARK: - 添加上拉下拉刷新的方法
    func addRefirsh(){
        
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            
            self.getWorkOrder(type: self.currentStatusBtn?.tag ?? 0)
        })
        
        
        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            
            self.getWorkOrder(type: self.currentStatusBtn?.tag ?? 0, pageIndex: self.pageNo + 1)
        })
        
        
    }
    
    // MARK: - 获取默认的项目的值来显示
    func getUserDefaultsProject() -> String {
        
        let dic = UserDefaults.standard.object(forKey: Const.YQProjectModel) as? [String : Any]
        
        var projectID  = ""
        
        if dic != nil {
            projectID = dic?["ID"] as! String
        }
        
        return projectID
        
    }


    @IBAction func statusBtnClick(_ sender: UIButton) {
        
        currentStatusBtn?.isSelected = false
        currentStatusBtn = sender
        currentStatusBtn?.isSelected = true
        pageNo = 0
        currentDatas.removeAll()
        tableView.reloadData()
        
        getWorkOrder(type: sender.tag)

        
        if sender.tag == 1{
            tableView.isEditing = false
            belowView.isHidden = true
        }else{
            belowView.isHidden = false
        }
    }

    
    // MARK: - 筛选按钮的点击执行的方法
    @IBAction func chooseBtnClick(_ sender: UIBarButtonItem) {
        
        //控制器回来的时候,调用了筛选按钮,然后的是调用了闭包,设置的代码块,进行的是筛选条件的读取的操作
        
        let vc = WorkOrderScreeningViewController.loadFromStoryboard(name: "WorkOrder") as! WorkOrderScreeningViewController
        vc.type = 2
        vc.doneBtnClickHandel = { parmat in
            
            //控制器出来的时候触发了筛选按钮,注意的这个 坑!
            
            self.getWorkOrder(type: self.currentStatusBtn!.tag,pageIndex: 0,dic: parmat)
            
            self.shouldReload = false
            
        }
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func electsBtnClick(_ sender: UIBarButtonItem) {

//        if waitProcessedBtn.isSelected {
//            tableView.setEditing(!tableView.isEditing, animated: true)
//            
//            belowView.isHidden = !tableView.isEditing
//        }

        
    }
    
    // MARK: - 全选的按钮的点击的情况
    @IBAction func leftBtnClick() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing{
            leftBtn.setTitle("取消全选", for: .normal)
            for index in 0..<currentDatas.count{
                let indexPath = IndexPath(row: currentDatas.count  - index - 1, section: 0)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            }
        }else{
            leftBtn.setTitle("全选", for: .normal)
        }
    }
    
    
    // MARK: - 一键督办的按钮的点击情况
    @IBAction func rightBtnClick() {
//        electsBtnClick(UIBarButtonItem())
        if tableView.indexPathsForSelectedRows == nil{
            //全部督办
            alert(message: "还没有选中需要督办的项", doneBlock: { (alertAction) in
                print("全部督办按钮被点击")
                
//                let arry = self.currentDatas.map{
//                    $0.workOrderId
//                }
//                self.surveillance(workOrderIds: arry)
//                self.electsBtnClick(UIBarButtonItem())
            })
            
            
        }else{//部分督办
            
            var temp = [String]()
            for indexPath in self.tableView.indexPathsForSelectedRows! {
                temp.append(currentDatas[indexPath.row].id)
            }
            surveillance(workOrderIds: temp)
            electsBtnClick(UIBarButtonItem())
        }
    }

    
    // MARK: - 接受通知的方法
    func selectionDidChange(noti: NSNotification){
        
        if tableView.indexPathsForSelectedRows == nil{
            
            leftBtn.setTitle("全部选择", for: .normal)
            
        }else{
            
            leftBtn.setTitle("全选", for: .normal)
        }
        
    }
    
    
    // MARK: - 加载搜索工单的方法
    func getWorkOrder(type: Int,pageIndex: Int = 0 ,dic: [String: Any] = [String: Any]() ){
        
        var status = ""
        if type == 0{
            //待督办
            status = "DDB"
        }else{
            //已督办
            status = "YDB"
        }
        
        //督办的筛选条件的制定情况,需要的是 进行传参限定
        var parmat = [String: Any]()
        parmat["STATUS"] = status
        parmat["pageIndex"] = pageIndex
        
        if startT != "" {
            parmat["STAR"] = startT
        }
        
        if endT != "" {
            
            parmat["END"] = endT
        }
        
        if park_ID != "" {
            
            parmat["PARK_ID"] = park_ID
        }
        
        //需要的是,补传的三个参数:
        if let start = dic["STAR"] {
        
            parmat["STAR"] = start
            startT = start as! String
        
        }
        if let end = dic["END"] {
            
            parmat["END"] = end
            endT = end as! String
            
        }
        
        if let parkID = dic["PARK_ID"] {
            
            parmat["PARK_ID"] = parkID
            park_ID = parkID as! String
            
        }
        
        
        
        // 取出所有的参数来 进行赋值
        for (key,value) in dic{
            parmat[key] = value
        }
        
        SVProgressHUD.show(withStatus: "加载中...")
        
        HttpClient.instance.get(path: URLPath.getSurveillanceWorkOrderList, parameters: parmat, success: { (response) in
            SVProgressHUD.dismiss()
            guard response.count > 0 else{
                SVProgressHUD.showError(withStatus: "数据为空")
                return
            }
            
            var temp = [WorkOrderModel]()
            if let arry = response["data"] as? Array<[String: Any]>{
                for dic in arry {
                    let model = WorkOrderModel(parmart: dic)
                    model.isSupervise = self.currentStatusBtn?.tag == 1
                    temp.append(model)
                }
            }
            
            if pageIndex == 0{
                
                self.pageNo = 0
                self.currentDatas = temp
                self.tableView.mj_header.endRefreshing()
                self.tableView.mj_footer.resetNoMoreData()
                
            }else{
                
                if temp.count > 0{
                    
                    self.pageNo = pageIndex
                    self.currentDatas.append(contentsOf: temp)
                    self.tableView.mj_footer.endRefreshing()
                    
                }else{
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
                

            }
            self.tableView.reloadData()
            
            self.shouldReload = true
            
        }) { (error) in
            SVProgressHUD.dismiss()
            self.shouldReload = true
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
        }
    }
    
    
    func surveillance(workOrderIds: Array<String>){
        
        var text = ""

        text = workOrderIds.reduce("", {$0 + "," + $1})
        text = (text as NSString).replacingCharacters(in: NSMakeRange(0, 1), with: "")
        
        HttpClient.instance.post(path: URLPath.batchsetSupervisestatus, parameters: ["SUPERVISE_IDS": text], success: { (response) in
                        
            SVProgressHUD.showSuccess(withStatus: "督办成功")
            self.getWorkOrder(type: 0)
            
        }) { (error) in
            
        }
        
    }
    
}




extension SurveillanceWorkOrderViewController: UITableViewDataSource, UITableViewDelegate{
    
    // MARK: - tableView的数据源和代理的方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SurveillanceWorkOrderCell
        
        cell = tableView.dequeueReusableCell(withIdentifier: "workOrder") as! SurveillanceWorkOrderCell
        cell.model = currentDatas[indexPath.row]
        cell.surveillanceBtnClickHandle = { [weak self] in
            self?.surveillance(workOrderIds: [(self?.currentDatas[indexPath.row].id)!])
        }
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.isEditing == true {
            
            return
        }
        
        let vc = WorkOrderProgressViewController.loadFromStoryboard(name: "WorkOrder") as! WorkOrderProgressViewController
        let model = currentDatas[indexPath.row]
        
        var parmat = [String: Any]()
        parmat["UNIT_STATUS"] = model.status
        parmat["PERSONTYPE"] = model.PERSONTYPE
        parmat["EXEC_PERSON_ID"] = model.execPersionId
        parmat["WORKUNIT_ID"] = model.workOrderId
        
        vc.parmate = parmat
        vc.workType = 1
        vc.hasDuban = (currentStatusBtn?.tag)!
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

