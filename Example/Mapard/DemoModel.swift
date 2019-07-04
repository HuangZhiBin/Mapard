//
//  DemoModel.swift
//  Mapard_Example
//
//  Created by huangzhibin on 2019/7/4.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import Mapard

class DemoModel: MapardModel {
    @objc dynamic var log1 : String?;
    @objc var title : String?;// [Mapard] 属性必须支持objc，否则转化失败
    @objc var time : Date?;
    @objc var data : DataModel?;
}

class DataModel: MapardModel {
    @objc var cities : [CityModel]?; // [Mapard] 必须为数组变量定义其类型，代码如下
    @objc var info : String?;
    @objc var type : OcInt?;
    
    required init() {
        super.init();
        // [Mapard]  为数组变量定义其类型
        self.arrayPropertyNameAndType = ["cities":"CityModel"];
    }
}

class CityModel: MapardModel {
    
    @objc var id : OcInt?;
    @objc var name : String?;
    @objc var population : OcInt?;
    @objc var latitude : OcDouble?;
    @objc var longitude : OcDouble?;
    @objc var isHot : OcBool?;
    
}
