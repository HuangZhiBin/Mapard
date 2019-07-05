# Mapard
### 将Dictionary转为Model

网络请求中很多返回数据都是Dictionary的格式，提供Dictionary转为Model的工具，将省去写mapper的时间，让开发更高效。

> Mapard is an iOS Utility that converts Dictionary to Model.

![](http://wxtopik.oss-cn-shanghai.aliyuncs.com/app/images/1545988181497.jpg)

### 语言要求
`Swift4.0`

### 引入
`pod 'Mapard'`

### 例子
```swift
// [Mapard] 1. Model类必须继承MapardModel
class DemoModel: MapardModel {
    @objc dynamic var log1 : String?;
    @objc var title : String?;// [Mapard] 属性必须支持objc，否则转化失败
    @objc var time : Date?;
    @objc var data : DataModel?;
}
```
（2）将Dictionary转为Model，只需要在初始化model后执行代码`testModel.modelFrom();`
```swift
    let testModel : DemoModel = DemoModel.init(coder: nil);
    model.setDict(responseDict);//responseDict is Dictionary<String, Any>;
```
------------

### 关于@objc不支持Int/Float/Double/Bool的情况
当model的属性不支持objc时,如变量是Int/Float/Double/Bool时，将无法成功转化（KVO）。可考虑使用OcNumber(OcInt/OcBool/OcLong/OcDouble等)
    

### 扩展
分析一下实际业务应用时可能遇到的情况。
- 1.&nbsp;Mapard的测试案例分为三种，data.json、data2.json、data3.json(参考文件夹/Mapard/Json/),针对不同的数据情况进行测试
- 2.&nbsp;Mapard当前支持的json变量涵盖大部分的常用类型，包括int/string/boolean/date/double/等类型
- 3.&nbsp;Mapard兼容**model互相嵌套**的情况
- 4.&nbsp;Mapard兼容数组为空数组、为nil的情况
- 5.&nbsp;Mapard兼容变量不存在，以及变量值为nil的情况
