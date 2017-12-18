//
//  YQVideoMonitorAndPatrolVC.swift
//  OpticalValleyUnite
//
//  Created by 杨庆 on 2017/12/7.
//  Copyright © 2017年 yangqing. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SVProgressHUD

class YQVideoMonitorAndPatrolVC: UIViewController {
    /// 属性列表
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var videoButton: UIButton!
    
    @IBOutlet weak var patrolButton: UIButton!
    
    @IBOutlet weak var backImageView: UIImageView!
    
    /// 传递的属性
    var prameterDict : NSDictionary?
    
    var patrolItemArray = [YQPatrolItemModel](){
        didSet{
            //创建添加scrollView
            let count = patrolItemArray.count
            self.contentScrollView.contentSize = CGSize.init(width: (UIScreen.main.bounds.size.width * CGFloat(count)), height: 0)
            contentScrollView.isPagingEnabled = true
            
            //创建添加子控件
            for indexN in 0..<count {
                
                let x = CGFloat(indexN) * contentScrollView.width
                let y = 0
                let width = contentScrollView.width
                let height = 600
                
                let model = patrolItemArray[indexN]
                
                
                switch model.checkType {
                case 1://是否达标
                    
                    let vc = YQPatrolItemWeatherViewController.init(nibName: "YQPatrolItemWeatherViewController", bundle: nil)
                    vc.contentIndex = indexN
                    vc.prameterDict = self.prameterDict
                    
                    //添加bottomView和传递模型
                    if  indexN == count - 1 {//最后项
                        
                        vc.bottomType = "last"
                        
                    }else{//next项
                        
                        vc.bottomType = "next"
                        
                    }
                    
                    //传递模型的数据
                    vc.model = model
                    
                    self.addChildViewController(vc)
                    vc.view.frame = CGRect.init(x: x, y: CGFloat(y), width: width, height: CGFloat(height))
                    
                    contentScrollView.addSubview(vc.view)
                    
                    break
                    
                case 2://评分
                    
                    let vc = YQPatrolItemScoreViewController.init(nibName: "YQPatrolItemScoreViewController", bundle: nil)
                    vc.contentIndex = indexN
                    vc.prameterDict = self.prameterDict
                    
                    //添加bottomView和传递模型
                    if  indexN == count - 1 {//最后项
                        
                        vc.bottomType = "last"
                        
                    }else{//next项
                        
                        vc.bottomType = "next"
                    }
                    
                    //传递模型的数据
                    vc.model = model
                    
                    self.addChildViewController(vc)
                    vc.view.frame = CGRect.init(x: x, y: CGFloat(y), width: width, height: CGFloat(height))
                    
                    contentScrollView.addSubview(vc.view)
                    
                    break
                    
                default:
                    break
                }
                
            }
        }
    }
    
    // MARK: - 视图生命周期的方法
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.contentScrollView.isDirectionalLockEnabled = true
        self.title = "巡查项"
    
        //连续调用的两个接口
        getMediaPlayerData()
        getPatrolItemTypeDada()
        
        //1.视频接口,巡查的接口
        self.videoButtonClick(self.videoButton)
        
        //2.添加media
        self.addMediaPlayerViewMethod()
        
        //3.接受通知类型
        setNotiesFunction()
        
    }
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//        super.viewWillAppear(true)
//        
//        let videoURL =  URL(string: "http://116.205.13.37:2020/34020000001320000002/live/34020000001320000002.m3u8")!
//        //定义一个视频播放器，通过本地文件路径初始化
//        let player = AVPlayer(url: videoURL)
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        self.present(playerViewController, animated: true) {
//            
//            playerViewController.player!.play()
//            
//        }
//    }
    
    // MARK: - 网络获取相应的数据的情况
    func getMediaPlayerData(){
        
        let insPointId = prameterDict?["videoConfigId"] as? Int ?? 0
        if insPointId != 0{
        
            var par = [String : Any]()
            par["videoConfigId"] = "\(insPointId)"
                
            HttpClient.instance.post(path: URLPath.getVideogetLive, parameters: par, success: { (respose) in
                
                //获取视频地址,显示播放
                let url = respose["interM3u8"] as? String
                DispatchQueue.main.async {
                    //获取url 来进行创建
                    
                }
                
            }) { (error) in
                SVProgressHUD.showError(withStatus: "视频失败,请检查网络!")
            }
        
        }else{
            //没有视频播放情况
            self.backImageView.image = UIImage.init(name: "")
        }
    }
    
    // MARK: - 获取巡查项类型的数据情况
    func getPatrolItemTypeDada(){
        
        let insPointId = self.prameterDict?["insPointId"] as? Int ?? 0
        
        var par = [String : Any]()
        par["insPointId"] = "\(insPointId)"
    
        HttpClient.instance.post(path: URLPath.getVideoItemFormByPointId, parameters: par, success: { (response) in
            
            var tempModel = [YQPatrolItemModel]()
            
            for temp in (response as? NSArray)! {
                
                tempModel.append(YQPatrolItemModel.init(dict: temp as! [String : Any]))
            }
            
            self.patrolItemArray = tempModel
            
        }) { (error) in
            
            SVProgressHUD.showError(withStatus: "巡查项获取失败,请检查网络!")
        }
        
    }
    
    // MARK: - 接受通知的方法
    func setNotiesFunction(){
        let center = NotificationCenter.default
        let notiesName = NSNotification.Name(rawValue: "NextViewNextNoties")

        center.addObserver(self, selector: #selector(notiesContentScrollView(noties : )), name: notiesName, object: nil)
        
    }
    
    func notiesContentScrollView(noties : Notification){
        
        let indexxx = noties.userInfo?["currentContentSize"] as! Int
        let insResultId = noties.userInfo?["insResultId"] as? Int
        
        self.contentScrollView.setContentOffset(
            CGPoint.init(x: self.contentScrollView.width * CGFloat(indexxx), y: 0), animated: true)
        
        if let vc = self.childViewControllers[indexxx] as? YQPatrolItemWeatherViewController {
            
            vc.insResultId = insResultId
        
        }
        
        if let vc = self.childViewControllers[indexxx] as? YQPatrolItemScoreViewController {
            
            vc.insResultId = insResultId
            
        }

        
    }
    
    // MARK: - 添加流媒体的播放视频项
    func addMediaPlayerViewMethod (){
        
        let videoURL =  URL(string: "http://116.205.13.37:2020/34020000001320000002/live/34020000001320000002.m3u8")!
        //定义一个视频播放器，通过本地文件路径初始化
        let player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.videoView.bounds
        //添加到界面上
        self.videoView.layer.addSublayer(playerLayer)
        //开始播放
        player.play()
    
    }
    
    @IBAction func videoButtonClick(_ sender: UIButton) {
        sender.isSelected = true
        self.patrolButton.isSelected = false
        self.videoView.isHidden = !sender.isSelected
        self.contentScrollView.isHidden = sender.isSelected
        
    }

    @IBAction func patrolButtonClick(_ sender: UIButton) {
        sender.isSelected = true
        self.videoButton.isSelected = false
        
        self.videoView.isHidden = sender.isSelected
        self.contentScrollView.isHidden = self.videoButton.isSelected
        
    }
    
}