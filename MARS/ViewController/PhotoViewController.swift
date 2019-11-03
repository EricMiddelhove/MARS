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
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var solLabel: UILabel!
    
    
    //MARK: Variables & Constants
    let networker = NetworkHandler()
    let STANDARD_TOP_SPACING:CGFloat = 23
    let STANDARD_FRONT_SPACING:CGFloat = 21
    let STABDARD_BACK_SPACING:CGFloat = 21
    let STANDARD_BOTTOM_SPACING:CGFloat = 23
    let tapRecognizer = UITapGestureRecognizer()
    
    var reportedRobot: Constants.Robots!
    var imagesOfSol: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Download Metadata
        loadingIndicator.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            self.networker.getLatestSol(from: self.reportedRobot)
            
            self.networker.getAllPictureMetadata(takenBy: self.reportedRobot)
        }

        scrollView.delegate = self
        
        photoButton.layer.borderWidth = 2
        photoButton.layer.borderColor = photoButton.currentTitleColor.cgColor
        photoButton.layer.cornerRadius = 10
        loadingIndicator.hidesWhenStopped = true
        
        //Image Downloaded Handler
        NotificationCenter.default.addObserver(self, selector: #selector(PhotoViewController.gotNewImageData(_:)), name: NSNotification.Name(rawValue: "NewImageData"), object: nil)
               
        //Meta Downloaded Handler
        NotificationCenter.default.addObserver(self, selector: #selector(PhotoViewController.metaDownloaded(_:)), name: NSNotification.Name(rawValue: "downloadedMetaData"), object: nil)
               
        //Start Downloading
               
        //Download Images
        
        //Ab hier übernimmt der metaDownload Handler, der nach abschluss des Metadata Downloads gecalled wird
        
    }
    
    //MARK: Actions
    
    //Heruntergeladene Bilder anzeigen
    @objc func gotNewImageData(_ notification: Notification){
        // Rufe addNewImage im main Thread auf, wegen den UI Zugriff
        DispatchQueue.main.sync{
            loadingIndicator.stopAnimating()
            self.addNewImageFrom(data: Constants.imageData!)
        }
    }

    //Initiale Bilder herunterladen
    @objc func metaDownloaded(_ notification: Notification){

        DispatchQueue.main.sync {
            loadingIndicator.stopAnimating()
        }
       
        
        
        if Constants.metadata.count > 4 {
            // Nur 3 Herunterladen
            
            for i in 0...3{
                DispatchQueue.global(qos: .userInitiated).async {
                    self.networker.downloadImageFrom(urlString: Constants.metadata[i].img_src)
                }
            }
        }else{
            //Alle Herunterladen

            if Constants.metadata.count == 0 {
                //Wenn keine Bilder vorhanden sind, nichts herunterladen
                return
            }
            
            //Sonst alle herunterladen
            for i in 0...Constants.metadata.count - 1{
                DispatchQueue.global(qos: .userInitiated).async {
                    self.networker.downloadImageFrom(urlString: Constants.metadata[i].img_src)
                }
            }
            
            DispatchQueue.main.sync {
                loadNextPictures()
            }
            
        }
        
        
    }
    
    //Listener für die Galerie speiechern Funktion
    @objc func imageButtonTapped(_ sender: UIButton){
        
        //Ignoriert die position im Bilder Array des PhotoViewControllers
        let image = sender.subviews[0] as! UIImageView
        
        addImageToLibrary(image.image!)
        
    }
    
    //MARK: Helper Functions
    var isInitialCall = true
    func addNewImageFrom(data:Data){
        
        if isInitialCall {
            solLabel.text = "Sol: " + String(networker.maxSol!)
            isInitialCall = false
        }
        
        let w = contentView.frame.width - STANDARD_FRONT_SPACING * 2  //WIDTH = HEIGHT
        let y = (STANDARD_TOP_SPACING + w) * CGFloat(contentView.subviews.count - 1)
        
        
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
        
        //wenn nötig vergrößerung des scroll views
        if currentHeight < newButton.frame.maxY {
            heightConstraint.constant += newButton.frame.height + STANDARD_TOP_SPACING
        }
        
        //Adding view to superview
        imagesOfSol += [newButton]
        print("Adde sol Data für Image " + String(contentView.subviews.count))
        Constants.solData[String(contentView.subviews.count)] = networker.maxSol!

        contentView.addSubview(newButton)
        
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
    
    func goToNextSol(){
        loadingIndicator.startAnimating()
        print("Gehe zu Nächstem Sol")
        
        //Aktualisiere den Sol
        networker.maxSol! -=  1
        
        //Lösche die images Array
        imagesOfSol = []
        print("Sol: \(networker.maxSol!)")
        print("Image count: \(imagesOfSol.count)")
        
        //Lade die neuen Metadaten herunter
        
        DispatchQueue.global().async {
            self.networker.getAllPictureMetadata(takenBy: self.reportedRobot)
            print("Metacount: \(Constants.metadata.count)")
        }
        
        //Gehe Weiter als wäre alles normal
    }
    
    //ONLY CALL IN MAIN THREAD
    func loadNextPictures(){
        
        
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        
        
        for i in imagesOfSol.count ... imagesOfSol.count + 1 {
            if i >= Constants.metadata.count {
                //Alle Bilder dieses Sols angezeigt
                
                goToNextSol()
                
                break
                
            } else {
                //Neue Bilder herunterladen
                for _ in 1...2 {
                    networker.downloadImageFrom(urlString: Constants.metadata[i].img_src)
                }
                
            }
        }
    }
}

//MARK: Extensions
extension PhotoViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        let pictureHeight = contentView.frame.width - STANDARD_FRONT_SPACING * 2
        let currentImageShown: Int!
                
        if offset >= 0{
            currentImageShown = Int(offset / (STANDARD_TOP_SPACING + pictureHeight))
        }else{
            currentImageShown = 0
        }
        
//        print(currentImageShown)
        
        if let sol = Constants.solData[String(currentImageShown!)]{
            solLabel.text = "Sol: " + String(sol) // DEBUG
        }
        
        
        
        // Am Boden angekommen
        if (offset + scrollView.frame.height == contentView.frame.height){ //Wenn am untersten ende des Views
            
            loadNextPictures()
        }
    }
}
