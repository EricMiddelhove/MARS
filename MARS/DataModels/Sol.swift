//
//  Sol.swift
//  MARS
//
//  Created by Eric Middelhove on 16.09.19.
//  Copyright © 2019 Eric Middelhove. All rights reserved.
//

import Foundation

class Sol: Codable{
    
    var AT: DataCollection
    var HWS: DataCollection
    var PRE: DataCollection
    
    var First_UTC: String
    var Last_UTC: String
    var Season: String
    
    
    //Expecting Array which contains Data with var names as keys
    init(from dict: NSDictionary){
        
        AT = DataCollection(from: (dict["AT"] as? NSDictionary) ?? [:])
        HWS = DataCollection(from: (dict["HWS"] as? NSDictionary ?? [:]))
        PRE = DataCollection(from: (dict["PRE"] as? NSDictionary ?? [:]))
        
        First_UTC = (dict["First_UTC"] as? String) ?? "No Data"
        Last_UTC = (dict["Last_UTC"] as? String) ?? "No Data"
        Season = (dict["Season"] as? String) ?? "No Data"
    }
    
}
