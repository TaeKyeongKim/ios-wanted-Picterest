//
//  UIImage+.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit

extension UIImageView {
  
  func setImage(urlSource: ImageEntity, completion: @escaping (UIImage) -> Void){
    ImageManager.shared.loadImage(urlSource: urlSource) { result in
      
      switch result {
      case .success(let data):
        guard let data = data,
              let loadedImage = UIImage(data: data)
        else {return}
        DispatchQueue.main.async {
          self.image = loadedImage
          completion(loadedImage)
        }
                
      case .failure(let error):
        print(error.localizedDescription)
      } 
    }
  }
  
}
