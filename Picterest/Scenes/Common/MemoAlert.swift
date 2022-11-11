//
//  Alert.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/29.
//


import UIKit

struct MemoAlert {
  static var memo: String?
  static func makeAlertController(title: String?,
                                  message: String,
                                  actions: MemoAlert.Action...,
                                  from controller: UIViewController) -> UIAlertController {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    actions.forEach({
      alertController.addAction($0.alertAction)
    })
    controller.present(alertController, animated: true)
    return alertController
  }
}

extension MemoAlert {
  
  typealias handler = ((String?)->Void)?
  
  enum Action{
    case ok (handler)
    case cancel
    
    private var title: String {
      switch self {
      case .ok:
        return "확인"
      case .cancel:
        return "취소"
      }
    }
    private var completion: handler {
      switch self {
      case .ok(let handler):
        return handler
      case .cancel:
        return nil
      }
    }
    
    var alertAction: UIAlertAction {
      return UIAlertAction(title: title, style: .default) { _ in
        if let handler = self.completion {
          handler(MemoAlert.memo)
        }
      }
    }
    
  }
}
