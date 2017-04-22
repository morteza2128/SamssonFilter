//
//  FilterObject.swift
//  CoreImageDemo
//
//  Created by Morteza Hoseinizade on 4/17/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit

class FilterObject: NSObject {

    
    var name  : String?
    var coreImageName : String?
    var parametrsCount : NSNumber?
    var parametrs : Array<ParametersObject>?
    var isUsed :Bool?
    
    
    init(jsonDict: [String : Any] ) {
        
        self.name           = jsonDict["name"] as? String
        self.coreImageName  = jsonDict["coreImageName"] as? String
        self.parametrs      = FilterCore.sharedInstance.parseParametrs(parametrs: jsonDict["parameters"] as! [[String : Any]])

    }
    
}
