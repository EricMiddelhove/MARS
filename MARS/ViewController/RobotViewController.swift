//
//  RobotViewController.swift
//  MARS
//
//  Created by Eric Middelhove on 23.09.19.
//  Copyright © 2019 Eric Middelhove. All rights reserved.
//

import Foundation
import UIKit

class RobotViewController: UIViewController{
    
    //---------------------------------------------------
    //
    //MARK: Variables and constants
    //
    var chosenRobot:Constants.Robots!

    //---------------------------------------------------
    //
    //MARK: IBOutlets
    //
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var otherButtons: UIStackView!
    @IBOutlet weak var stackContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chosenRobot = .NONE
        
        photoButton.layer.borderWidth = 2
        photoButton.layer.borderColor = photoButton.currentTitleColor.cgColor
        photoButton.layer.cornerRadius = 10
        
    }

    //---------------------------------------------------
    //
    //MARK: IBActions
    //
    @IBAction func curiosityButtonPressed(_ sender: Any) {
        chosenRobot = .CURIOSITY
        performSegue(withIdentifier: "toPhotoViewController", sender: self)
    }
    @IBAction func opportunityButtonPressed(_ sender: Any) {
        chosenRobot = .OPPORTUNITY
        performSegue(withIdentifier: "toPhotoViewController", sender: self)
    }
    @IBAction func spiritButtonPressed(_ sender: Any) {
        chosenRobot = .SPIRIT
        performSegue(withIdentifier: "toPhotoViewController", sender: self)
    }
    
    //---------------------------------------------------
    //
    //MARK: Override functions
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? PhotoViewController {
            dest.reportedRobot = chosenRobot
        }
    }

    @IBAction func unwindToRobotView(_ segue: UIStoryboardSegue){
    }

}
