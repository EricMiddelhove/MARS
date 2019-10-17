//
//  Constants.swift
//  MARS
//
//  Created by Eric Middelhove on 23.09.19.
//  Copyright © 2019 Eric Middelhove. All rights reserved.
//

import Foundation

class Constants{
    enum Robots: String{
        case SPIRIT = "spirit"
        case OPPORTUNITY = "opportunity"
        case CURIOSITY = "curiosity"
        case NONE = ""
    }
    
    static var SolData: Sol = Sol(from: [:])
    static var metadata: [PhotoMetadata]!
    static var imageData: Data? = nil

}
