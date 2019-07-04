//
//  AsObjective.swift
//
//  Created by huangzhibin on 2019/5/24.
//

import UIKit

// MARK: - Int

public class OcInt: NSObject {
    
    public var intValue : Int = 0;
    
    init(_ value: Int) {
        super.init();
        self.intValue = value;
    }
    
}

public func OC(_ value: Int) -> OcInt{
    return OcInt.init(value);
}

// MARK: - Long

public class OcLong: NSObject {
    
    public var longValue : CLongLong = 0;
    
    init(_ value: CLongLong) {
        super.init();
        self.longValue = value;
    }
    
}

public func OC(_ value: CLongLong) -> OcLong{
    return OcLong.init(value);
}

// MARK: - Double

public class OcDouble: NSObject {
    
    public var doubleValue : Double = 0;
    
    init(_ value: Double) {
        super.init();
        self.doubleValue = value;
    }
    
}

public func OC(_ value: Double) -> OcDouble{
    return OcDouble.init(value);
}

// MARK: - Bool

public class OcBool: NSObject {
    
    public var boolValue : Bool = false;
    
    init(_ value: Bool) {
        super.init();
        self.boolValue = value;
    }
    
}

public func OC(_ value: Bool) -> OcBool{
    return OcBool.init(value);
}
