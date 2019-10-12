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
    var metadata: [PhotoMetadata]!
    var images: [UIImageView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        photoButton.layer.borderWidth = 2
        photoButton.layer.borderColor = photoButton.currentTitleColor.cgColor
        photoButton.layer.cornerRadius = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        metadata = networker.getAllPictureMetadata(takenBy: reportedRobot)
        for i in 0...3 {
            addNewImageFrom(data: networker.getImageFrom(urlString: metadata[i].img_src)!)
        }
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
        //Todoj: Resizing contentView
    
        
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

extension PhotoViewController: UIScrollViewDelegate{

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if (offset + scrollView.frame.height == contentView.frame.height){ //Wenn am untersten ende des Views
            
            for i in images.count ... images.count + 1 {
                if i < metadata.count {
                    addNewImageFrom(data: networker.getImageFrom(urlString: metadata[i].img_src)!)
                } else {
                    break
                }
            }
        }
    }
    
}
