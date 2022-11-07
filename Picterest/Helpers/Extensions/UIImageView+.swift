//
//  UIImage+.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit

extension UIImageView {
  
  private var dataTransferService: NetworkService {
    return NetworkService()
  }
  
  func setImage(urlSource: URL){
    dataTransferService.request(on: URLRequest(url: urlSource)){ result in
      
      switch result {
      case .success(let data):
        guard let loadedImage = UIImage(data: data) else {return}
        DispatchQueue.main.async {
          self.image = loadedImage
        }
      case .failure(let error):
        print(error.localizedDescription)
      } 
    }
  }
  
}
