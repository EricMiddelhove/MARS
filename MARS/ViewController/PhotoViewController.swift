//
//  PhotoViewController.swift
//  MARS
//
//  Created by Eric Middelhove on 19.09.19.
//  Copyright © 2019 Eric Middelhove. All rights reserved.
//

import Foundation
import UIKit
import Photos

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
    let tapRecognizer = UITapGestureRecognizer()
    
    var reportedRobot: Constants.Robots!
    var images: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        tapRecognizer.delegate = self
        
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
        // Rufe addNewImage im main Thread auf, wegen den UI Zugriff
        DispatchQueue.main.sync{
            self.addNewImageFrom(data: Constants.imageData!)
        }
    }
    
    @objc func metaDownloaded(_ notification: Notification){
        for i in 1...4 {
            DispatchQueue.global(qos: .userInitiated).async {
                self.networker.downloadImageFrom(urlString: Constants.metadata[i].img_src)
            }
        }
    }
    
    @objc func imageButtonTapped(_ sender: UIButton){
        
        let image = sender.subviews[0] as! UIImageView
        
        addImageToLibrary(image.image!)
        
    }
    
    //MARK: Functions
    func addNewImageFrom(data:Data){
        let w = contentView.frame.width - STANDARD_FRONT_SPACING * 2  //WIDTH = HEIGHT
        let y = (STANDARD_TOP_SPACING + w) * CGFloat(images.count)
        
        
        //Creating view for UIImage
        let rect = CGRect(x: STANDARD_FRONT_SPACING, y: y, width: w, height: w) as CGRect
        
        let newButton = UIButton(frame: rect)
        newButton.addTarget(self, action: #selector(self.imageButtonTapped(_:)), for: .touchUpInside)
        
        guard data == data else{return}
        let image = UIImage(data: data)
        
        
        let imageRect = CGRect(x: 0, y: 0, width: w, height: w)
        let imageView = UIImageView(frame: imageRect)
        
        imageView.image = image
        newButton.addSubview(imageView)

        let currentHeight = contentView.frame.height

        if currentHeight < newButton.frame.maxY {
            heightConstraint.constant += newButton.frame.height + STANDARD_TOP_SPACING
        }
        
        //Adding view to superview
        images += [newButton]
        contentView.addSubview(newButton)
        
        //Hiding loading label
        loadingLabel.isHidden = true
    }
    
    func addImageToLibrary(_ image: UIImage){
        
        let alert = UIAlertController(title: "Save?", message: "Save this picture to your library?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "no", style: .default, handler: nil))
        

        alert.addAction(UIAlertAction(title: "yes", style: .default,handler:{ (alertAction) in
             PHPhotoLibrary.shared().performChanges({
                       let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                       
                       let addAssetRequest = PHAssetCollectionChangeRequest()
                       
                       addAssetRequest.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
                   }) { (successful, error) in
                       if(successful){
                           print("Saved to Library")
                       }
                   }
        }))
        
            
        self.present(alert, animated: true)
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
                    
                    for _ in 1...2 {
                        networker.downloadImageFrom(urlString: Constants.metadata[i].img_src)
                    }
                    
                } else {
                    break
                }
            }
        }
    }
}
extension PhotoViewController: UIGestureRecognizerDelegate{
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("ja lol ey")
    }
    
}
