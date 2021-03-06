//
//  WorkOrderProgressViewController.swift
//  OpticalValleyUnite
//
//  Created by 贺思佳 on 2017/1/13.
//  Copyright © 2017年 贺思佳. All rights reserved.
//

import UIKit
import SVProgressHUD
import RealmSwift

enum OperationType: Int{
    case none = 0, waitDistribution, waitMeetsList, waitProcessing, waitExecuting, waitDone, waitAppraise
}

class WorkOrderProgressViewController: UIViewController {
    
    ///新增的属性backDB属性的情况
    var backDB : Bool = false
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var models = [WorkHistoryModel]()
    
    //设备类的工单模型数据
    var workOrderDetalModel: WorkOrderDetailModel?
    var parmate: [String: Any]?
    var callbackModels = [CallbackModel]()
    var taskModels = [ExecSectionModel]()
    
    var equimentModel: EquimentModel?
    
    var leftBtnClickHandel: (() -> ())?
    var rightBtnClickHandel: (() -> ())?
    weak var listVc: WorkOrderViewController?
    var timer: Timer?
    //0代表工单详情 1代表督办详情
    var workType = 0
    var hasDuban = 0
    
    var taskCell: ExecutDetailCell?
    //缓存taskRemark的信息
    var taskRemarkText : String?
    
    var partListData : NSArray?
    
    
    @IBOutlet weak var dubanBtn: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    @IBOutlet weak var oprationView: UIView!
    var detailsCell: WorkOrderDetailsCell?
    
    var type = OperationType.none {
        
        didSet{
            
            var leftText = ""
            var rightText = ""
            
            switch type {
            //待派发
            case .waitDistribution:
                leftBtnClickHandel = choosePeopleBtnClick
                rightBtnClickHandel = cloosePeopleClose
                
                leftText = ""
                rightText = "派发"
                leftBtn.isHidden = true
       
                setupTimer()
            //待接单
            case .waitMeetsList:
                leftBtnClickHandel = meetsList
                rightBtnClickHandel = meetsListClose
                
                leftText = "接单"
                rightText = "退回"
                leftBtn.isHidden = false
                
                setupTimer()
                
            //待处理
            case .waitProcessing:
                leftBtnClickHandel = processingBtnClick
                rightBtnClickHandel = meetsListClose
                
                leftText = "处理"
                rightText = "退回"
                leftBtn.isHidden = false
             
                
            //待执行
            case .waitExecuting, .waitDone:
                leftBtnClickHandel = executingBtnClick
                rightBtnClickHandel = meetsListClose
                
                leftText = "执行"
                rightText = "退回"
                leftBtn.isHidden = false
                
                //待完成
                
            //待评价
            case .waitAppraise:
                leftBtnClickHandel = waitappraisal
                rightBtnClickHandel = meetsListClose
                
                leftText = ""
                rightText = "评价"
            
                leftBtn.isHidden = true
                
            default:
                leftBtn.isHidden = true
                rightBtn.isHidden = true
                break
            }
            
            leftBtn.setTitle(leftText, for: .normal)
            rightBtn.setTitle(rightText, for: .normal)
        }
    }
    

    func setupTimer(){
        
        if #available(iOS 10.0, *) {
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                
                for cell in self.tableView.visibleCells{
                    if let cell = cell as? WorkOrderOprationCell{
                        
                        cell.oneSecond()
                        
                    }
                }
                
            })
            
            timer?.fire()
            
        } else {
            
        }
    
    }
    
    // MARK: - 视图生命周期的方法
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //让行高可以自动调节,设置预估行高
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        //重点的注册加载cell的行高的情况
        let nib = UINib(nibName: "WorkOrderDistributionCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "WorkOrderDistributionCell")
        let nib2 = UINib(nibName: "WorkOrderOprationCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "WorkOrderOprationCell")
        
        let nib3 = UINib(nibName: "OrderReturningCell", bundle: nil)
        tableView.register(nib3, forCellReuseIdentifier: "OrderReturningCell")
        
        let nib4 = UINib(nibName: "AppraisalCell", bundle: nil)
        tableView.register(nib4, forCellReuseIdentifier: "AppraisalCell")
        
        let nib5 = UINib(nibName: "ExecutDetailCell", bundle: nil)
        tableView.register(nib5, forCellReuseIdentifier: "ExecutDetailCell")
        
        let nib6 = UINib(nibName: "ExecutEmergencyCell", bundle: nil)
        tableView.register(nib6, forCellReuseIdentifier: "ExecutEmergencyCell")
        
        let nib7 = UINib(nibName: "WorkOrderDetailsCell", bundle: nil)
        tableView.register(nib7, forCellReuseIdentifier: "xiangqing")
        
        if workType == 1 && hasDuban == 0{
            oprationView.isHidden = true
        }
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 0)
        tableView.separatorStyle = .singleLine
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getData()
        
        getWorkDetail()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer?.invalidate()
        
    }

    
    // MARK: - left,rightButton的点击
    @IBAction func leftBtnClick() {
        
        switch type {
            
        //待派发
        case .waitDistribution:
            break
            
        //待接单
        case .waitMeetsList:
            meetsList()
            
        //待处理
        case .waitProcessing:
            processingBtnClick()
            
        //待执行
        case .waitExecuting, .waitDone:
            
            executingBtnClick()
            //待完成
            
        //待评价
        case .waitAppraise:
            break
            
        default:
            break
        }

    }
    
    @IBAction func rightBtnClick() {
        
        switch type {
        //待派发
        case .waitDistribution:
            choosePeopleBtnClick()
            
        //待接单
        case .waitMeetsList:
            meetsListClose()
            
        //待处理
        case .waitProcessing:
            meetsListClose()
            
        //待执行
        case .waitExecuting, .waitDone:
            meetsListClose()
            //待完成
            
        //待评价
        case .waitAppraise:
            waitappraisal()
            
        default:
            break
        }
        
    }
    
    // MARK: - 刷新状态
    func reloadStatus(status: Int){
        
        //离线需要的是更新数据库的接口
        if backDB {
            
            SVProgressHUD.showSuccess(withStatus: "工单完成,状态显示成功!")
            let realm = try! Realm()
            realm.beginWrite()

            //进行的工单的状态的筛选查询
            workOrderDetalModel?.statu = "\(status)"
            workOrderDetalModel?.status = status
            
            try! realm.commitWrite()
            
            getData()
            
            getWorkDetail()
            
            return
        }
        
        //有线的请求!
        parmate?["UNIT_STATUS"] = status
        
        SVProgressHUD.show(withStatus: "加载中...")
        
        HttpClient.instance.get(path: URLPath.getWorkDetail, parameters: parmate, success: { (respose) in
            SVProgressHUD.dismiss()
            var temp = [WorkHistoryModel]()
            for dic in respose["histories"] as! Array<[String: Any]>{
                temp.append(WorkHistoryModel(parmart: dic))
            }
            var temp2 = [CallbackModel]()
            for dic in respose["callbacks"] as! Array<[String: Any]>{
                temp2.append(CallbackModel(parmart: dic))
            }
            self.callbackModels = temp2
            
            if let type = respose["type"] as? NSString{
                self.type = OperationType(rawValue:Int(type as String)!)!
            }else{
                self.type = OperationType(rawValue:0)!
            }
            
            if let dic = respose as? [String: Any]{
                let model = WorkOrderDetailModel(parmart: dic)
                self.workOrderDetalModel = model
            }
            
            self.models = temp
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
            SVProgressHUD.dismiss()
        }
        
    }
    
    
    // MARK: - 拿到工单详情后再次拿到设备
    func getWorkDetail(){
        
        if backDB {
            
            let id = parmate?["WORKUNIT_ID"] as? String
            
            autoreleasepool {
                
                let realm = try! Realm()
                
                //查询WorkHistoryModel的项目表
                let WorkHistoryM = realm.objects(WorkHistoryModel111.self).filter("id == %@", id!).first
                let workList = WorkHistoryM?.childs
                var dict = [String : Any]()
                var tempppp = [WorkHistoryModel]()
                
                for temp in workList! {
                    
                    dict["person_name"] = temp.person_name
                    dict["unit_status"] = temp.status
                    dict["time"] = temp.time
                    dict["EVALUATE_SCORE"] = temp.source
                    dict["text"] = temp.text
                    dict["EVALUATE_TEXT"] = temp.content
                    let model = WorkHistoryModel(parmart: dict)
                   
                    tempppp.append(model)
                    
                }

                
                //查callback项目
                let callBack = realm.objects(CallbackModel.self).filter("id == %@", id!)
                for temp in callBack {
                    
                    self.callbackModels.append(temp)
                }
                
                //查的type的值情况
                let detailModel = realm.objects(WorkOrderDetailModel.self).filter("id == %@", id!).first
                if let type = detailModel?.type{
                    self.type = OperationType(rawValue:Int(type as String)!)!
                    
                }else{
                    
                    self.type = OperationType(rawValue:0)!
                }
                
                self.workOrderDetalModel = detailModel
                
                //查设备展开项目
                let model = realm.objects(EquimentModel.self).filter("id == %@", id!).first
                
                self.equimentModel = model
                
                //总体赋值,刷新列表项目
                self.models = tempppp
                self.tableView.reloadData()

            }
            
            return
        }
        
        
        SVProgressHUD.show(withStatus: "加载中...")
        
        HttpClient.instance.get(path: URLPath.getWorkDetail, parameters: parmate, success: { (respose) in
            
            SVProgressHUD.dismiss()
            
            if respose as? [String : Any] == nil {
                
                SVProgressHUD.showError(withStatus: "没有更多数据")
                return
                
            }
            //添加收藏 parkid的 缓存
            //  respose["PARK_ID"] 的值是需要的情况
            let PackId = respose["PARK_ID"] as! String
            UserDefaults.standard.set(PackId, forKey: Const.YQParkID)
            
            var temp = [WorkHistoryModel]()
            
            //print(respose["histories"])
            
            for dic in respose["histories"] as! Array<[String: Any]>{
                
                temp.append(WorkHistoryModel(parmart: dic))
            }
            
            var temp2 = [CallbackModel]()
            
            for dic in respose["callbacks"] as! Array<[String: Any]>{
                
                temp2.append(CallbackModel(parmart: dic))
            }
            
            self.callbackModels = temp2

            if let type = respose["type"] as? NSString{
                self.type = OperationType(rawValue:Int(type as String)!)!
             }else{
                self.type = OperationType(rawValue:0)!
            }
            
            if let dic = respose as? [String: Any]{
                
                let model = WorkOrderDetailModel(parmart: dic)
                self.workOrderDetalModel = model
                
//                print(model.equipment_id)
                
                //这里是获取了设备id的方法
                self.getEquipment(model.equipment_id)
            }
            
            self.models = temp
            
            self.tableView.reloadData()
            
        }) { (error) in
            
            print(error)
            
            SVProgressHUD.dismiss()
        }
        
        
    }
    
    
    // MARK: - 拿到设备设置的接口
    func getEquipment(_ equipment: Double){
        
        if equipment == -1{//没有设备的列表,拿到的是原始默认值
            return
        }
        
        let equipmentInt = Int64(equipment)
        let equipmentString = "\(equipmentInt)"
        let parmate = ["id": equipmentString]
        
        HttpClient.instance.get(path: URLPath.getEquipmentDetail, parameters: parmate, success: { (response) in

            if let dic = response as? [String: Any]{
                
                self.equimentModel = EquimentModel(parmart: dic)
                self.tableView.reloadData()

            }

        }) { (error) in
            
        }
    }
    
    // MARK: - 拿到数据
    func getData(){
        
        if backDB {//离线工单
            //查询所有的表的内容情况
            let id = parmate?["WORKUNIT_ID"] as? String
            
            autoreleasepool {
                
                let realm = try! Realm()
                let model = realm.objects(ExecSectionModel.self).filter("workOrderId == %@", id!)
                
                for temp in model{
                
                    self.taskModels.append(temp)
                
                }
                
                if let cell = self.taskCell{
                    
                    cell.models = self.taskModels
                    
                    //查一下detail的数据项的表
                    let offLineWorkerDetail = realm.objects(offLineWorkOrderDetailModel.self).filter("ID == %@", id!).first
                    cell.remarkTextView.text = offLineWorkerDetail?.REMARKS
                    
                }
                
                if let cell = self.detailsCell{
                    
                    cell.contentLabel.text = self.taskModels.first?.TASK_DESCRIPTION
                }

            }
            
            return
        }
        
        
//        var parmat = [String: Any]()
//        parmat["WORKUNIT_ID"] = workOrderDetalModel?.id
//        SVProgressHUD.show(withStatus: "加载任务中")
        HttpClient.instance.get(path: URLPath.getTaskList, parameters: parmate, success: { (response) in
            
//            SVProgressHUD.dismiss()
            var temp = [ExecSectionModel]()
            
            if response["task"] as? [String: Any] == nil{
                
                SVProgressHUD.showError(withStatus: "加载任务失败!")
                return
            }
            
            //注意的后台的数据结构的调整,以前是应用的数组集合来放字典,现在的是直接放了一个字典,没有数组了
            let dic = response["task"] as! [String: Any]
            let model = ExecSectionModel(parmart: dic)
            temp.append(model)

            self.taskModels = temp
            self.taskRemarkText = response["remark"] as? String
            
            let partList = response["partsList"] as? NSArray
            self.partListData = partList
            
            if let cell = self.taskCell{
                
                cell.models = temp
                cell.partList = partList

                cell.remarkTextView.text = response["remark"] as? String
            }
            
            if let cell = self.detailsCell{
                
                cell.contentLabel.text = temp.first?.TASK_DESCRIPTION
            }

        }) { (error) in

        }
        
    }

    
    // MARK: - 不同的data对应生成不同cell的方法(重点)
    func getCell(model: WorkHistoryModel) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch model.status {
            
        case -1://工单生成
            
            cell = tableView.dequeueReusableCell(withIdentifier: "WorkOrderDescription")!
            let reportName = workOrderDetalModel?.reportPeopleName
            if reportName == "" {
                
//                (cell as! WorkOrderCreatCell).model?.reportPeopleName = model.person_name
                let realm = try! Realm()
                realm.beginWrite()
                
                workOrderDetalModel?.reportPeopleName = model.person_name
                try! realm.commitWrite()
                
            }
            
            (cell as! WorkOrderCreatCell).model = workOrderDetalModel
        
        case 4://工单生成
            
            cell = tableView.dequeueReusableCell(withIdentifier: "OrderReturningCell")!
            (cell as! OrderReturningCell).model = model
            
        case 8://工单评价
            
            cell = tableView.dequeueReusableCell(withIdentifier: "AppraisalCell")!
            (cell as! AppraisalCell).model = model
            
        case 7://工单执行
            
            if workOrderDetalModel?.orderType == "应急工单"{//应急工单的原型cell
                
                cell = tableView.dequeueReusableCell(withIdentifier: "ExecutEmergencyCell")!
                (cell as! ExecutEmergencyCell).detailModel = workOrderDetalModel
                (cell as! ExecutEmergencyCell).model = model
                
            }else{//计划工单的原型cell
                
                let cell2 = tableView.dequeueReusableCell(withIdentifier: "ExecutDetailCell") as! ExecutDetailCell
                //传递备注的信息
                cell2.remarkTest = self.taskRemarkText
                
                cell2.models = self.taskModels
                
                if taskCell == nil {
                    
                    cell2.partList = self.partListData
                }
                
                
                taskCell = cell2
                cell2.superTableView = tableView
                
                cell = cell2
                
            }
            
        case 10...12,2...3,5...6://工单生成
            
            cell = tableView.dequeueReusableCell(withIdentifier: "stutas")!
            (cell as! WorkOrderStutasCell).detailModel = workOrderDetalModel
            (cell as! WorkOrderStutasCell).model = model
            
        case 0,1://已派发
            
            cell = tableView.dequeueReusableCell(withIdentifier: "WorkOrderDistributionCell")!
            
            (cell as! WorkOrderDistributionCell).model2 = workOrderDetalModel
            (cell as! WorkOrderDistributionCell).model = model
            
            
        default:
            break
        }
        
        return cell
        
    }
    
    
    //MARK: - 操作按钮点击
    //派单按钮点击
    func choosePeopleBtnClick(){
        
        let vc = ChoosePersonViewController.loadFromStoryboard(name: "WorkOrder") as! ChoosePersonViewController
        vc.workId = parmate?["WORKUNIT_ID"] as! String
        vc.parkId = (workOrderDetalModel?.PARK_ID)!
        vc.ProgressVC = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //工单关闭
    func cloosePeopleClose(){
        var parmat = [String: Any]()
        parmat["WORKUNIT_ID"] = parmate?["WORKUNIT_ID"] as! String
        parmat["UNIT_STATUS"] = 3
        
        request(paramat: parmat, completionHandler: { [weak self] in
            _ = self?.navigationController?.popViewController(animated: true)
        })
    }
    
    //接单按钮点击
    func meetsList(){
        
        var parmat = [String: Any]()
        parmat["WORKUNIT_ID"] = parmate?["WORKUNIT_ID"] as! String
        parmat["UNIT_STATUS"] = 5
        
        request(paramat: parmat, completionHandler: {
            self.getWorkDetail()
        })
        
    }
    
    //工单退回
    func meetsListClose(){

        OprationConfirmationView.show(doneBtnClickHandel: { [weak self] text in
            
            var parmat = [String: Any]()
            
            parmat["WORKUNIT_ID"] = self?.parmate?["WORKUNIT_ID"] as! String
            if text != ""{
                parmat["DESCRIPTION"] = text
            }
            
            HttpClient.instance.post(path: URLPath.workunitReturn, parameters: parmat, success: { (response) in
                _ = self?.navigationController?.popViewController(animated: true)
                self?.listVc?.reload()
                SVProgressHUD.showSuccess(withStatus: "工单退回成功")
                
            }) { (error) in
                
            }
        })
    }
    //处理
    func processingBtnClick(){
        
        var parmat = [String: Any]()
        parmat["WORKUNIT_ID"] = parmate?["WORKUNIT_ID"] as! String
        parmat["UNIT_STATUS"] = 6
        request(paramat: parmat, completionHandler: {
            self.getWorkDetail()
        })
    }
    
    func executingBtnClick(){
        let  vc = ExecutingViewConttroller.loadFromStoryboard(name: "WorkOrder") as! ExecutingViewConttroller
        vc.workOrderDetalModel = workOrderDetalModel
        //离线的工单属性设置
        if backDB {
            
            vc.backDB = backDB
            vc.parmate = parmate
        }
        
        vc.ProgressVC = self
        
        //添加新增是否有 查看工单的详情
        let emergencyTrue = self.workOrderDetalModel?.picture != "" ? true : false
       
        vc.emergencyWorkOrderIsTrue = emergencyTrue
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    //待评价
    func waitappraisal(){
        
        let  vc = AppraisalViewController.loadFromStoryboard(name: "WorkOrder") as! AppraisalViewController
        vc.model = workOrderDetalModel
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - 点击督办按钮的执行的方法
    @IBAction func dubanBtnClick(_ sender: UIButton) {
        
        let text = workOrderDetalModel!.id
        HttpClient.instance.post(path: URLPath.batchsetSupervisestatus, parameters: ["SUPERVISE_IDS": text], success: { (response) in
            
            SVProgressHUD.showSuccess(withStatus: "督办成功")
            self.heightConstraint.constant = 0
            //重新的调用接口,加载数据刷新表格
            self.reloadStatus(status: 0)
            
            self.view.setNeedsLayout()
            
        }) { (error) in
            
        }
        
        
    }
    
    //MARK: - HTTP
    func request(paramat: [String: Any], completionHandler: (() -> ())?){
        
        SVProgressHUD.show(withStatus: "加载中")
        HttpClient.instance.post(path: URLPath.workunitExecuSave, parameters: paramat, success: { (response) in
            SVProgressHUD.dismiss()
            if let completionHandler = completionHandler{
                completionHandler()
//                self.getWorkDetail()
            }else{
                SVProgressHUD.showSuccess(withStatus: "操作成功")
            }
            
        }) { (error) in
            
        }
    }


//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if let vc = segue.destination as? CallBackListViewController{
//            
//            
//        }
//    }
    

}

extension WorkOrderProgressViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if models.count >= 0{
            
            return models.count + 1

        }else{
            return 0
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            var cell = UITableViewCell()
            
            if indexPath.row == 0{
                
                //显示设备详情的cell 就是第一行的 所有的数据和逻辑
                let DetailsCell = tableView.dequeueReusableCell(withIdentifier: "xiangqing") as! WorkOrderDetailsCell
                DetailsCell.model = self.workOrderDetalModel
                DetailsCell.hasCallBackList = callbackModels.count != 0
                DetailsCell.superVC = self
                
                
                cell = DetailsCell
                detailsCell = DetailsCell
                
                if workOrderDetalModel?.orderType == "计划工单"{//计划工单
                    
                    DetailsCell.reportTypeLabel.isHidden = true
                    DetailsCell.workReportTypeLable.isHidden = true
                    DetailsCell.workReportLabelHieghtConstraint.constant  = 0
                    DetailsCell.workReportHightConstraint.constant = -12
                    
                }
                
                DetailsCell.changedHeight = {
                    
                    tableView.reloadData()
                }
                
                DetailsCell.equipmentModel = self.equimentModel
                
                if (self.taskModels.first?.TASK_DESCRIPTION) != ""{
                    
                    DetailsCell.contentLabel.text = self.taskModels.first?.TASK_DESCRIPTION
                
                }
                
            }else{
                
                let model = models[indexPath.row - 1]
                
                let cell2 = getCell(model: model )
                cell = cell2
            }
        
        let dotView = cell.contentView.viewWithTag(777)
        
        if let view = dotView{
            
            if indexPath.row == 1{
                
                view.backgroundColor = UIColor.blue
            }else{
                
                view.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xcccccc)
            }
        }
   
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if let cell = cell as? WorkOrderStutasCell{
            
            if cell.model?.status == 7{
//                executingBtnClick()
                let  vc = ExecutingViewConttroller.loadFromStoryboard(name: "WorkOrder") as! ExecutingViewConttroller
                vc.workOrderDetalModel = workOrderDetalModel
                vc.ProgressVC = self
                vc.isToSee = true
                vc.hisriyModel = cell.model
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
}
