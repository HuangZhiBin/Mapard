//
//  ViewController.swift
//  Mapard
//
//  Created by ikrboy@163.com on 07/04/2019.
//  Copyright (c) 2019 ikrboy@163.com. All rights reserved.
//

import UIKit
import Mapard

class ViewController: UIViewController {
    
    var textView: UITextView!;

    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view, typically from a nib.
        
        self.textView = UITextView.init(frame: CGRect.init(x: 0, y: 20, width: 320, height: 700));
        self.textView.isEditable = false;
        self.view.addSubview(self.textView);
        
        var str = "";
        str = str + self.testData(1);
        str = str + self.testData(2);
        str = str + self.testData(3);
        
        self.textView.text = str;
    }
    
    func testData(_ dataOrder: Int) -> String{
        let jsonPath = Bundle.main.path(forResource: "data" + String(dataOrder), ofType: "json");
        var data : Data;
        var result : Any?;
        do {
            data = try Data.init(contentsOf: URL.init(fileURLWithPath: jsonPath!));
            result = try JSONSerialization.jsonObject(with: data, options: .allowFragments);
        } catch let error as NSError {
            print ("Error: \(error.domain)")
        }
        let testModel : DemoModel = DemoModel.init();
        testModel.setDict(result as! Dictionary<String, Any>);
        return printModel(model: testModel);
    }
    
    func printModel(model : DemoModel) -> String{
        var str = "====================================================\n";
        str = str + "title : " + (model.title ?? "nil") + "\n";
        str = str + "time : " + ((model.time != nil) ? "\(model.time!)":  "nil") + "\n";
        str = str + "data : " + ((model.data != nil) ? "":  "nil") + "\n";
        if(model.data != nil){
            
            str = str + "       - info : " + ((model.data!.info != nil) ? (model.data!.info)!:  "nil") + "\n";
            str = str + "       - type : " + ((model.data!.type != nil) ? "\((model.data!.type?.intValue)!)":  "nil") + "\n";
            
            str = str + "       - cities : " + ((model.data!.cities != nil) ? "("+String(describing: model.data!.cities!.count)+")":  "nil") + "\n";
            
            if(model.data!.cities != nil){
                for (index,item) in model.data!.cities!.enumerated(){
                    str = str + "              - (item " + String(index) + ")\n";
                    str = str + "                     - id : " + ((item.id != nil) ? "\((item.id)!)":  "nil") + "\n";
                    str = str + "                     - name : " + ((item.name != nil) ? "\((item.name)!)":  "nil") + "\n";
                    str = str + "                     - latitude : " + ((item.latitude != nil) ? "\((item.latitude?.doubleValue)!)":  "nil") + "\n";
                    str = str + "                     - longitude : " + ((item.longitude != nil) ? "\((item.longitude?.doubleValue)!)":  "nil") + "\n";
                    str = str + "                     - population : " + ((item.population != nil) ? "\((item.population?.intValue)!)":  "nil") + "\n";
                    str = str + "                     - isHot : " + ((item.isHot != nil) ? "\((item.isHot?.boolValue)!)":  "nil") + "\n";
                }
                
            }
        }
        print(str);
        return str;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

