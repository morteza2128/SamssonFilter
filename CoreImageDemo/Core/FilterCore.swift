//
//  FilterCore.swift
//  CoreImageDemo
//
//  Created by Morteza Hoseinizade on 4/17/17.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import UIKit

class FilterCore: NSObject {

    
    static let sharedInstance = FilterCore()

    
    func parseFilters() -> [FilterObject]
    {
        
        var piListArr: NSArray?
        if let path = Bundle.main.path(forResource: "PropertyList", ofType: "plist") {
            piListArr = NSArray(contentsOfFile: path)
        }
        
        if piListArr != nil {
          
            var filtersArr = [FilterObject]()
            
            let filtersTemp = piListArr
            for  dict in filtersTemp!{
                
                let filterObj = FilterObject(jsonDict: dict as! [String : Any])
                filtersArr.append(filterObj)
                
            }
            
            return filtersArr
        }
        else{
            
            return []
        }
        
    }
    
    func parseParametrs( parametrs: [[String : Any]] ) -> [ParametersObject]
    {
    
        var parametrsArr = [ParametersObject]()
        
        let parametrsTemp = parametrs
        for  dict in parametrsTemp{
            
            let parametrObj = ParametersObject(jsonDict: dict)
            parametrsArr.append(parametrObj)
            
        }
        
        return parametrsArr
    
    }
}
