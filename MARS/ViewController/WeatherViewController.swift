//
//  WeatherViewController.swift
//  MARS
//
//  Created by Eric Middelhove on 18.09.19.
//  Copyright © 2019 Eric Middelhove. All rights reserved.
//

import Foundation
import UIKit

class WeatherViewController: UIViewController{
    
    //---------------------------------------------------
    //
    //MARK: Variables and constants
    //
    let AT_STAND = "average temperature: "
    let MAXT_STAND = "maximum temperature: "
    let MINT_STAND = "minimum temperature: "
    let WS_STAND = "wind speed: "
    let PRE_STAND = "average pressure: "
    let SOL_STAND = "Sol: "
    let networker = NetworkHandler()
    
    var sol: Sol!

    //---------------------------------------------------
    //
    //MARK: IBOutlets
    //
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var solLabel: UILabel!
    @IBOutlet weak var atLabel: UILabel!
    @IBOutlet weak var maxTLabel: UILabel!
    @IBOutlet weak var minTLabel: UILabel!
    @IBOutlet weak var wsLabel: UILabel!
    @IBOutlet weak var preLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoButton.layer.borderWidth = 2
        photoButton.layer.borderColor = photoButton.currentTitleColor.cgColor
        photoButton.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        sol = networker.getWeatherData()
        
        solLabel.text = SOL_STAND + networker.latestSolKey
        atLabel.text = AT_STAND + sol.AT.av + " °C"
        minTLabel.text = MINT_STAND + sol.AT.mn + " °C"
        maxTLabel.text = MAXT_STAND + sol.AT.mx + " °C"
        wsLabel.text = WS_STAND + String(sol.HWS.avRaw) + " m/s"            // String(...avRaw) raw value da normales automatisch in °C umgewandelt wird ...
        preLabel.text = PRE_STAND + String(sol.PRE.avRaw) + " Pa"
    }
    
}