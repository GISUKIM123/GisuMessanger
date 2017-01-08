//
//  Extensions.swift
//  gisuchat
//
//  Created by GISU KIM on 2016-12-09.
//  Copyright © 2016 GISU KIM. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(urlString: String){
        //no flshing image for the next list
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: (urlString as NSString)){
            self.image = cachedImage
            return
        }
        
        let url = NSURL(string: urlString)
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request){
            (data, response, error) in
            //download hit an error so lets return out
            if error != nil{
                print(error!)
                return
            }
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!){
                    imageCache.setObject(downloadedImage, forKey: (urlString as NSString))
                    
                    self.image = downloadedImage
                }
                
                
                
                //                    cell.imageView?.image = UIImage(data: data!)
            }
        }
        dataTask.resume()        
    }
    
}
