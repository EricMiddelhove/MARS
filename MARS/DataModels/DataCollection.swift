//
//  DataCollection.swift
//  MARS
//
//  Created by Eric Middelhove on 16.09.19.
//  Copyright © 2019 Eric Middelhove. All rights reserved.
//

import Foundation

class DataCollection: Codable{
    //Double type and in Farenheit
    var avRaw: Double
    var ctRaw: Double
    var mnRaw: Double
    var mxRaw: Double
    
    //Good Metric stuff
    var av: String = ""
    var ct: String = ""
    var mn: String = ""
    var mx: String = ""

    init(from dict: NSDictionary){
        
        
        avRaw = (dict["av"]) as? Double ?? 0
        ctRaw = (dict["ct"] as? Double) ?? 0
        mnRaw = (dict["mn"] as? Double) ?? 0
        mxRaw = (dict["mx"] as? Double) ?? 0
        
        av = String(self.convertToC(f: avRaw))
        ct = String(self.convertToC(f: ctRaw))
        mn = String(self.convertToC(f: mnRaw))
        mx = String(self.convertToC(f: mxRaw))
     
        
        
    }
    
    init(){
        avRaw = 0
        ctRaw = 0
        mnRaw = 0
        mxRaw = 0
    }
    
    //---------------------------------------------------
    //
    //MARK: Helper functions
    //
    func convertToC(f: Double) -> Double{
        //  T(°C) = (T(°F) - 32) / 1.8
        var c = (f - 32) / 1.8
        
        c = c * 10
        c = c.rounded()
        c = c / 10
        
        return c
    }
}
