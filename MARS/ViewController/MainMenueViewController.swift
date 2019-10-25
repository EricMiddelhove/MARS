//
//  ViewController.swift
//  MARS
//
//  Created by Eric Middelhove on 10.09.19.
//  Copyright © 2019 Eric Middelhove. All rights reserved.
//

import UIKit

class MainMenueViewController: UIViewController {

    //---------------------------------------------------
    //
    //MARK: IBOutlets
    //
    
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var weatherButton: UIButton!
    
    let networker = NetworkHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global().async {
            self.networker.getWeatherData()
        }
        
        photoButton.layer.borderWidth = 2
        photoButton.layer.borderColor = photoButton.currentTitleColor.cgColor
        photoButton.layer.cornerRadius = 10
        
        weatherButton.layer.borderWidth = 2
        weatherButton.layer.borderColor = weatherButton.currentTitleColor.cgColor
        weatherButton.layer.cornerRadius = 10
        
    }
    
    //---------------------------------------------------
    //
    //MARK: IBActions
    //
    @IBAction func weatherButtonPressed(_ sender: UIButton) {
        
    }

    
    //---------------------------------------------------
    //
    //MARK: Segues
    //
    @IBAction func unwindToMainMenue(segue: UIStoryboardSegue) {
        //
    }

    
    //---------------------------------------------------
    //
    //MARK: Helper
    //
   
}

