//
//  EmptyIndicatorView.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/30.
//

import UIKit

final class EmptyIndicatorView: UIView {
  
  private let emptyImage: UIImageView = {
    let imageView = UIImageView()
    let image = UIImage(named: "inspiration")
    imageView.image = image
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.backgroundColor = .clear
    label.numberOfLines = 0
    label.text = "(아직) 아무것도 없습니다!"
    label.font = .systemFont(ofSize: 25, weight: .bold)
    return label
  }()
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.numberOfLines = 0
    label.text = "이미지를 탐색하고 영감을\n 주는 이미지를 저장해보세요."
    label.textAlignment = .center
    label.backgroundColor = .clear
    label.font = .systemFont(ofSize: 17, weight: .medium)
    return label
  }()
  
  private lazy var stackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
    stackView.backgroundColor = .white
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.spacing = UIStackView.spacingUseSystem
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

private extension EmptyIndicatorView {
  func setConstraints() {
    
    self.addSubview(emptyImage)
    self.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      emptyImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 100),
      emptyImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      emptyImage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      emptyImage.heightAnchor.constraint(equalToConstant: 260),
      
      stackView.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 20),
      stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
    ])
  }
}

