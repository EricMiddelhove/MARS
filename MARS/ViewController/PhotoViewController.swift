//
//  PhotoViewController.swift
//  MARS
//
//  Created by Eric Middelhove on 19.09.19.
//  Copyright © 2019 Eric Middelhove. All rights reserved.
//

import Foundation
import UIKit

class PhotoViewController: UIViewController{
    //MARK: Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var loadingLabel: UILabel!
    
    
    
    //MARK: Variables & Constants
    let networker = NetworkHandler()
    let STANDARD_TOP_SPACING:CGFloat = 23
    let STANDARD_FRONT_SPACING:CGFloat = 21
    let STABDARD_BACK_SPACING:CGFloat = 21
    let STANDARD_BOTTOM_SPACING:CGFloat = 23
    
    
    var reportedRobot: Constants.Robots!
    var images: [UIImageView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        photoButton.layer.borderWidth = 2
        photoButton.layer.borderColor = photoButton.currentTitleColor.cgColor
        photoButton.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Image Downloaded Handler
        NotificationCenter.default.addObserver(self, selector: #selector(PhotoViewController.gotNewImageData(_:)), name: NSNotification.Name(rawValue: "NewImageData"), object: nil)
        
        //Meta Downloaded Handler
        NotificationCenter.default.addObserver(self, selector: #selector(PhotoViewController.metaDownloaded(_:)), name: NSNotification.Name(rawValue: "downloadedMetaData"), object: nil)
        
        //Start Downloading
        
        //Download Metadata
        print("Call meta download")

        DispatchQueue.global(qos: .userInitiated).async {
            self.networker.getAllPictureMetadata(takenBy: self.reportedRobot)
        }
        print("Called meta download")

        //Download Images
       
        //Ab hier übernimmt der metaDownload Handler, der nach abschluss des Metadata Downloads gecalled wird
    }
    //MARK: Actions
    @objc func gotNewImageData(_ notification: Notification){
        print("nachricht Empfangen")
        // Rufe addNewImage im main Thread auf, wegen den UI Zugriff
        DispatchQueue.main.sync{
            self.addNewImageFrom(data: Constants.imageData!)
        }
    }
    
    @objc func metaDownloaded(_ notification: Notification){
        for i in 1...4 {
            print("Call download")
                   
            DispatchQueue.global(qos: .userInitiated).async {
                self.networker.downloadImageFrom(urlString: Constants.metadata[i].img_src)
            }
                   
            print(" Called download")

        }
        print("all downloads triggered")
    }
    //MARK: Functions

    func addNewImageFrom(data:Data){
        let w = contentView.frame.width - STANDARD_FRONT_SPACING * 2  //WIDTH = HEIGHT
        let y = (STANDARD_TOP_SPACING + w) * CGFloat(images.count)
        
        
        //Creating view for UIImage
        let rect = CGRect(x: STANDARD_FRONT_SPACING, y: y, width: w, height: w) as CGRect
        let newImageView = UIImageView(frame: rect)
        
        guard data == data else{
            return
        }
        
        let image = UIImage(data: data)
        
        let currentHeight = contentView.frame.height

        if currentHeight < newImageView.frame.maxY {
            heightConstraint.constant += newImageView.frame.height + STANDARD_TOP_SPACING
        }
        
        //Adding view to superview
        newImageView.image = image
        images += [newImageView]
        
        contentView.addSubview(newImageView)
        loadingLabel.isHidden = true
    }
}
//MARK: Extensions
extension PhotoViewController: UIScrollViewDelegate{

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if (offset + scrollView.frame.height == contentView.frame.height){ //Wenn am untersten ende des Views
            
            for i in images.count ... images.count + 1 {
                if i < Constants.metadata.count {
                    //Neue Bilder herunterladen
                    
                    for i in 1...2 {
                        networker.downloadImageFrom(urlString: Constants.metadata[i].img_src)
                    }
                    
                } else {
                    break
                }
            }
        }
    }
    
}
