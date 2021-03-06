//
//  MapViewController.swift
//  OpticalValleyUnite
//
//  Created by 贺思佳 on 2017/1/20.
//  Copyright © 2017年 贺思佳. All rights reserved.
//

import UIKit


class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MAMapView!
    
    var locationManager = AMapLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapSetup()
    }

     private func  mapSetup(){
        
        AMapServices.shared().enableHTTPS = true
        mapView.showsUserLocation = true;
        mapView.userTrackingMode = .follow;
        mapView.delegate = self as MAMapViewDelegate
        mapView.zoomLevel = 15.0
        mapView.distanceFilter = 100.0 //位移10米才进行的定位操作

        
        // 带逆地理信息的一次定位（返回坐标和地址信息）
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        //   定位超时时间，最低2s，此处设置为2s
        self.locationManager.locationTimeout = 5;
        //   逆地理请求超时时间，最低2s，此处设置为2s
        self.locationManager.reGeocodeTimeout = 5;
        
        locationManager.requestLocation(withReGeocode: true, completionBlock:{
            [weak self]  location, regeocode,error in
            if let error = error{
                print(error.localizedDescription)
            }
            if let regeocode = regeocode{
                print(regeocode)

                self?.mapView.setCenter((location?.coordinate)!, animated: true)
            }
            }
        )
    }
}


extension MapViewController: MAMapViewDelegate{
    func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
        //        print(mapView.userLocation.location)
        self.mapView.setCenter((mapView.userLocation!.coordinate), animated: true)

    }
}

