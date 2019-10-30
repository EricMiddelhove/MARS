//
//  NetworkHandler.swift
//  MARS
//
//  Created by Eric Middelhove on 14.09.19.
//  Copyright © 2019 Eric Middelhove. All rights reserved.
//

import Foundation
import UIKit
import Network


class NetworkHandler{

    //MARK: Variables and constants

    let session = URLSession.shared
    let WEATHER = "https://api.nasa.gov/insight_weather/?api_key=2V9ACrQ50aZcc6lprgYd00WbFFAMRNA9LdtdzQKQ&feedtype=json&ver=1.0"
    
    let IMG_META_BASE = "https://api.nasa.gov/mars-photos/api/v1/rovers/"
    let IMG_PARAMETERS = "/photos?sol=100&api_key=2V9ACrQ50aZcc6lprgYd00WbFFAMRNA9LdtdzQKQ"
    
    let weatherSemaphore = DispatchSemaphore(value: 0)
    let metaSemaphore = DispatchSemaphore(value: 0)
    let downloadSemaphore = DispatchSemaphore(value: 0)
    
    var maxSol: Int?
    
    let roverManifest = [String:Any].self
    
    //MARK: Functions
    
    //Returns Sol object containing weatherdata
    func getWeatherData(){
        
        print("Lade Wetterdaten herunter")
        
        let url = URL(string: WEATHER)!
        print(url)
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
           
        URLSession.shared.dataTask(with: request) { (dat, res, err) in
                
            guard let data = dat else {
                print("no Data")
                return
            }
                
            guard res == res else {
                print("No Response ")
                return
            }
            
            if let error = err {
                print("Error: \(error)")
                return
            }
                

            do{
                    
                var dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                dictionary!["validity_checks"] = "" as AnyObject
                    
                let dict = dictionary!
                let solKeys = dict["sol_keys"]! as! NSArray
                    
                Constants.latestSolKey = solKeys[solKeys.count-1] as! String // Suche den letzten Sol als String -> key für das gesamte dictionary
                
                Constants.SolData = Sol(from: dict[Constants.latestSolKey] as! NSDictionary)
                
            } catch {
                print("Data decode failed \(error)")
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "weatherdataRecieved"), object: nil)
            
        }.resume()
        
        print("Wetterdaten herunterladen abgeschlossen")
    }
    
    func getLatestSol(from robot: Constants.Robots){
        
        let decoder = JSONDecoder()
        
        var manifestUrl = "https://api.nasa.gov/mars-photos/api/v1/manifests/"
                
        //Passe download URL nach Roboter an (Manifest und Meta)
        if robot == .CURIOSITY{
            manifestUrl += "Curiosity"
        }else if robot == .OPPORTUNITY{
            manifestUrl += "Opportunity"
        }else if robot == .SPIRIT{
            manifestUrl += "Spirit"
        }else{
            fatalError("No Robot chosen");
        }
                
        manifestUrl += "?api_key=2V9ACrQ50aZcc6lprgYd00WbFFAMRNA9LdtdzQKQ"
            
        //Lade das manifest herunter
        //        print(manifestUrl)
        print("Lade Manifest herunter (latest sol)")
        var req = URLRequest(url: URL(string: manifestUrl)!)
        req.httpMethod = "GET"
        let semaphore = DispatchSemaphore(value: 0)
            
                
        var pManifest: PhotoManifest!
                
        URLSession.shared.dataTask(with: req) { (dat, res, err) in
            guard let data = dat else {
                print("No Manifest Data")
                return
            }
            guard let _ = res else{
                print("No response")
                return
            }
                                    
            if let error = err{
                print("manifest error: \(error)")
                return
            }
                               
            do{
                
                pManifest = try decoder.decode(PhotoManifest.self, from: data)
                
                self.maxSol = self.maxSol ?? pManifest.photo_manifest.max_sol
                
            }catch{
                fatalError("\(error)")
            }
                            
                               
            semaphore.signal()
        }.resume()
        semaphore.wait()
        print("Manifest herunterladen abgeschlossen")
        
    }
    
    func getAllPictureMetadata(takenBy robot: Constants.Robots){
        
        let decoder = JSONDecoder()
        
        var photos: Photos!
        
        var urlString:String = IMG_META_BASE
        
        if robot == .CURIOSITY{
            urlString += "curiosity"
        }else if robot == .OPPORTUNITY{
            urlString += "opportunity"
        }else if robot == .SPIRIT{
            urlString += "spirit"
        }else{
            fatalError("No Robot chosen");
        }

        
        // Lade die Metadaten herunter
        
        print("Lade Photometadaten herunter")
        urlString += "/photos?sol=" + String(maxSol!) + "&api_key=2V9ACrQ50aZcc6lprgYd00WbFFAMRNA9LdtdzQKQ"
        
        
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (d, r, e) in
            
            guard let data = d else{
                print("No Data")
                return
            }

            guard r == r else{
                print("No Response")
                return
            }

            if let err = e {
                print("\(err)")
                return
            }
            
            do{
                let p = try decoder.decode(Photos.self, from: data)
                photos = p
            }catch{
                fatalError("\(error)")
            }
            
            Constants.metadata = photos.photos
            print("Photometa herunterladen abgeschlossen")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "downloadedMetaData"), object: self)
            
        }.resume()
    }
    
    //Posts image data in Constants class
    func downloadImageFrom(urlString: String){
        let url = URL(string: urlString)!
        
//        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        var data: Data?
        
        URLSession.shared.dataTask(with: request) { (d, r, e) in
            guard let dat = d else {
                print("No Data")
                return
            }
                    
            guard r == r else {
                print("No Response")
                return
            }
                    
            if let err = e {
                print("ERROR: \(err)")
            }
                    
            data = dat
            Constants.imageData = data
                
                
            NotificationCenter.default.post(name: Notification.Name(rawValue: "NewImageData"), object: self)
                
                
        }.resume()
        
    }
}
//MARK: Structs
struct Photos:Codable{
    var photos: [PhotoMetadata]
}
struct PhotoMetadata: Codable{
    var id: Int = 0
    var sol: Int = 0
    var img_src: String = ""
    var earth_date: String = ""
    
}


struct PhotoManifest:Codable{
    var photo_manifest: Manifest
}
struct Manifest:Codable {
    var max_sol: Int
}
