//
//  ParametersObject.swift
//  CoreImageDemo
//
//  Created by Morteza Hoseinizade on 4/17/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit

class ParametersObject: NSObject {

    
    var name  : String?
    var max : Float?
    var min : Float?
    
    init(jsonDict: [String : Any] ) {
        
        self.name = jsonDict["id"] as? String
        self.max  = jsonDict["max"] as? Float
        self.min  = jsonDict["min"] as? Float
    }
}
