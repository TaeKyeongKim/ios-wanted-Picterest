//
//  AppAppearance.swift
//  Picterest
//
//  Created by Kai Kim on 2022/11/06.
//

import Foundation

final class AppConfiguration {
  
  lazy var apiKey: String = {
    guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "ApiKey") as? String else {
      fatalError("Apikey is missing")
    }
    return apiKey
  }()
    
  lazy var apiBaseURL: String = {
    guard let apiBaseURL = Bundle.main.object(forInfoDictionaryKey: "ApiBaseURL") as? String else {
      fatalError("ApiBaseURL is missing")
    }
    return apiBaseURL
  }()
  
  lazy var imageBaseURL: String = {
    guard let imageBaseURL = Bundle.main.object(forInfoDictionaryKey: "ImageBaseURL") as? String else {
      fatalError("ApiBaseURL is missing")
    }
    return imageBaseURL
  }()
  
  lazy var httpsScheme = "https"
 
  
  lazy var httpScheme = "http"
  
}
