//
//  MapardMapper.swift
//  Mapard
//
//  Created by bin on 2018/12/27.
//  Copyright © 2018年 BinHuang. All rights reserved.
//

import UIKit

private var arrayTypeNamesKey: Void?

let valueTypesMap: Dictionary<String, String> = [
    "c" : "Int8",
    "s" : "Int16",
    "i" : "Int32",
    "q" : "Int", //also: Int64, NSInteger, only true on 64 bit platforms
    "S" : "UInt16",
    "I" : "UInt32",
    "Q" : "UInt", //also UInt64, only true on 64 bit platforms
    "B" : "Bool",
    "d" : "Double",
    "f" : "Float",
    "{" : "Decimal"
]

//let SPACE_NAME = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;

/**
 ViewController的View的扩展方法
 */


public extension MapardModel {
    
    @objc var arrayPropertyNameAndType : [String : String]? {
        get {
            return objc_getAssociatedObject(self, &arrayTypeNamesKey) as? [String : String] ;
        }
        set(newValue) {
            objc_setAssociatedObject(self, &arrayTypeNamesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    };
    
    private func mapForProperty(obj: AnyObject, dict: Dictionary<String, Any>, typeName : String, propertyName: String){
        let propertyValue = dict[propertyName];
        
        if propertyValue == nil || propertyValue is NSNull {
            return;
        }
        
        //print("propertyName=\(propertyName),typeName=\(typeName)");
        
        if(typeName == "NSString") {
            obj.setValue(propertyValue, forKey: propertyName);
        }
        else if(typeName == "NSNumber") {
            if(propertyValue is Bool){
                obj.setValue((propertyValue as! Bool) ? NSNumber.init(value: true) : NSNumber.init(value: false) , forKey: propertyName);
                return;
            }
            obj.setValue(propertyValue, forKey: propertyName);
        }
        else if(typeName == "NSDecimalNumber") {
            obj.setValue(propertyValue, forKey: propertyName);
        }
        else if(typeName.hasSuffix("OcInt")) {
            obj.setValue(OcInt(propertyValue as! Int), forKey: propertyName);
        }
        else if(typeName.hasSuffix("OcLong")) {
            obj.setValue(OcLong(propertyValue as! CLongLong), forKey: propertyName);
        }
        else if(typeName.hasSuffix("OcBool")) {
            obj.setValue(OcBool(propertyValue as! Bool), forKey: propertyName);
        }
        else if(typeName.hasSuffix("OcDouble")) {
            obj.setValue(OcDouble(propertyValue as! Double), forKey: propertyName);
        }
        else if(typeName == "NSDate") {
            let dateStr :String = propertyValue as! String;
            if(dateStr.count == 10){
                let date : Int = Int(dateStr)!;
                obj.setValue(Date.init(timeIntervalSince1970: TimeInterval(date)), forKey: propertyName);
            }
            else if(dateStr.count == 13){
                let date : Double = Double(dateStr)!/1000;
                obj.setValue(Date.init(timeIntervalSince1970: TimeInterval(date)), forKey: propertyName);
            }
        }
        else if(typeName == "NSArray"){
            var array : [AnyObject] = [];
            
            guard let arr : [Any] = propertyValue as? Array else {
                return;
            }
            
//            obj.setValue([], forKey: propertyName);
//            let arrayType : Array.Type = type(of: obj.value(forKey: propertyName) as! Array<Any>)
//            let carType = arrayType.Element.self  // Car.Type
//            print("arr type = " + String(describing: carType))           // "Car"
            
            guard ((obj as! MapardModel).arrayPropertyNameAndType != nil) else {
                fatalError("should add arrayPropertyNameAndType for array " + propertyName);
            }
            
            let arrTypeName : String = (obj as! MapardModel).arrayPropertyNameAndType![propertyName]!;
            let SPACE_NAME = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String;
            let vcClass: AnyClass? = NSClassFromString(SPACE_NAME + "." + arrTypeName) //VCName:表示试图控制器的类名
            // Swift中如果想通过一个Class来创建一个对象, 必须告诉系统这个Class的确切类型
            let typeClass : MapardModel.Type = vcClass as! MapardModel.Type;
            
            for arrItem in arr{
                let modelDict : Dictionary<String,Any> = arrItem as! Dictionary<String, Any>;
                
                let model = typeClass.init();
                
                let properties : [String:String] = self.getProperties(model.classForCoder);
                for item in properties.keys{
                    let typeName : String = properties[item]!;
                    let propertyName : String = item;
                    
                    self.mapForProperty(obj: model, dict:modelDict, typeName: typeName, propertyName: propertyName);
                }
                
                array.append(model);
            }
            
            obj.setValue(array, forKey: propertyName);
        }
        else if(NSClassFromString(typeName) != nil){//typeName.hasSuffix("Model")
            guard let modelDict : Dictionary<String,Any> = propertyValue as? Dictionary<String, Any> else {
                return;
            };
            
            let vcClass: AnyClass? = NSClassFromString(typeName) //VCName:表示试图控制器的类名
            // Swift中如果想通过一个Class来创建一个对象, 必须告诉系统这个Class的确切类型
            let typeClass : MapardModel.Type = vcClass as! MapardModel.Type;
            let model = typeClass.init();
            
            let properties : [String:String] = self.getProperties(model.classForCoder);
            for item in properties.keys{
                let typeName : String = properties[item]!;
                let propertyName = item;
                
                self.mapForProperty(obj: model, dict:modelDict, typeName: typeName, propertyName: propertyName);
            }
            
            obj.setValue(model, forKey: propertyName);
        }
        else{
            obj.setValue(propertyValue, forKey: propertyName);
        }
    }
    
    @objc func setDict(_ dataDict : Dictionary<String,Any>){
        let properties : [String:String] = self.getProperties(self.classForCoder);
        for item in properties.keys{
            let typeName : String = properties[item]!;
            let propertyName : String = item;
            self.mapForProperty(obj: self, dict: dataDict, typeName: typeName, propertyName: propertyName);
        }
    }
    
    func getAllProperties(obj : AnyObject) -> [String]{
        var properties : [String] = [];
        var count: UInt32 = 0
        //获取类的属性列表,返回属性列表的数组,可选项
        
        let list = class_copyPropertyList(obj.classForCoder, &count)
        //print("属性个数:\(count)")
        //遍历数组
        for i in 0..<Int(count) {
            //根据下标获取属性
            let pty = list?[i]
            //获取属性的名称<C语言字符串>
            //转换过程:Int8 -> Byte -> Char -> C语言字符串
            let cName = property_getName(pty!)
            //转换成String的字符串
            let name = String(utf8String: cName)
            //            //print(name!);
            properties.append(name!);
        }
        free(list) //释放list
        return properties;
    }
    
    /// 获取属性名
    ///
    /// - Parameter property: 属性对象
    /// - Returns: 属性名
    func getNameOf(property: objc_property_t) -> String? {
        guard
            let name: NSString = NSString(utf8String: property_getName(property))
            else { return nil }
        return name as String
    }
    
    /// attributes对应的类型
    ///
    /// - Parameter attributes: attributes
    /// - Returns: 类型名
    private func valueType(withAttributes attributes: String) -> String? {
        let tmp = attributes as NSString
        let letter = tmp.substring(with: NSMakeRange(1, 1))
        guard let type = valueTypesMap[letter] else { return nil }
        return type
    }
    
    /// 获取属性类型
    ///
    /// - Parameter property: 属性对象
    /// - Returns: 属性类型
    func getTypeOf(property: objc_property_t) -> String? {
        guard let attributesAsNSString: NSString = NSString(utf8String: property_getAttributes(property)!) else { return nil }
        let attributes = attributesAsNSString as String
        let slices = attributes.components(separatedBy: "\"")
        guard slices.count > 1 else { return valueType(withAttributes: attributes) }
        let objectClassName = slices[1]
        return objectClassName
    }
    
    func getProperties(_ theClass: AnyClass? = nil) -> [String : String] {
        var count = UInt32()
        guard let properties = class_copyPropertyList((theClass == nil ? self.classForCoder : theClass), &count) else { return [:] }
        var types: [String : String] = [:]
        for i in 0..<Int(count) {
            let property: objc_property_t = properties[i]
            /// 获取属性名
            guard let name = getNameOf(property: property)
                else { continue }
            /// 获取属性类型
            let type = getTypeOf(property: property)
            types[name] = type
            //            print(name);
            //            print(type!);
            //            print("=====");
        }
        free(properties);
        
        //增加父类
        if theClass == nil {
            if(self.superclass != nil && NSStringFromClass((self.superclass?.class())!) != NSStringFromClass(NSObject.classForCoder())){
                let typesOfSuper = self.getProperties(self.superclass);
                for key in typesOfSuper.keys{
                    types[key] = typesOfSuper[key];
                }
            }
        }
        else{
            if(theClass?.superclass != nil && NSStringFromClass((theClass?.superclass())!) != NSStringFromClass(NSObject.classForCoder())){
                let typeOfSuper = self.getProperties(theClass?.superclass());
                for key in typeOfSuper.keys{
                    types[key] = typeOfSuper[key];
                }
            }
        }
        
        return types
    }
    
    /*
    func getProperties(obj : AnyObject) -> [String:String]{
        var properties : [String:String] = [:];
        var count: UInt32 = 0;
        let list = class_copyPropertyList(obj.classForCoder, &count);
        for i in 0..<Int(count) {
            //根据下标获取属性
            let pty : objc_property_t? = list?[i]
            //获取属性的名称<C语言字符串>
            //转换过程:Int8 -> Byte -> Char -> C语言字符串
            let cName = property_getName(pty!)
            let tName = property_copyAttributeValue(pty!, "T");
            //转换成String的字符串
            let name : String = String(utf8String: cName)!
            let typeName : String = String(utf8String: tName!)!
            let realTypeName = String((typeName as NSString).replacingOccurrences(of: "@", with: "").replacingOccurrences(of: "\"", with: ""));
            properties[name] = realTypeName;
        }
        free(list) //释放list
        return properties;
    }*/
    
}

//extension Array {
//    var elementType : String? {
//        get {
//            return objc_getAssociatedObject(self, &arrayTypeNamesKey) as? String;
//        }
//        set(newValue) {
//            objc_setAssociatedObject(self, &arrayTypeNamesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        }
//    };
//}
