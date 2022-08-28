//
//  ImageCell.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit

final class ImageCell: UICollectionViewCell {
  
  static let id = "ImageCell"
  //  private var model: ImageEntity?
  private var model: ImageViewModel?
  var saveDidTap: ((ImageViewModel) -> Void)?
  
  private let likeImage: UIImage? = {
    let image = UIImage(systemName: "star.fill")
    return image
  }()
  
  private let defaultLikeImage: UIImage? = {
    let image = UIImage(systemName: "star")
    return image
  }()
  
  private lazy var likeButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = .clear
    button.tintColor = UIColor(red: 0.9882352941, green: 0.7607843137, blue: 0, alpha: 1)
    button.setImage(defaultLikeImage, for: .normal)
    button.addTarget(self, action: #selector(saveButtonDidTap), for: .touchUpInside)
    return button
  }()
  
  private let memoLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.backgroundColor = .clear
    label.font = .systemFont(ofSize: 17, weight: .medium)
    return label
  }()
  
  private lazy var labelStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [likeButton, memoLabel])
    stackView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing
    stackView.spacing = UIStackView.spacingUseSystem
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 15
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private func setConstraints() {
    
    contentView.addSubview(imageView)
    contentView.addSubview(labelStackView)
    
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      
      labelStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
      labelStackView.heightAnchor.constraint(equalToConstant: 50),
      labelStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      labelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    ])
  }
  
  @objc private func saveButtonDidTap(){
    guard let model = self.model else {return}
    if model.isLiked == false {
      saveDidTap?(model)
    }
  }
  
  private func setLikeButtonToUndoLike() {
    likeButton.setImage(defaultLikeImage, for: .normal)
  }
  
  private func setCellToSaveState(model: Image) {
    setLikeButtonToOn()
    self.memoLabel.text = model.memo
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setConstraints()
    layer.cornerRadius = 15
    clipsToBounds = true
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func prepareForReuse() {
    imageView.image = nil
    memoLabel.text = nil
    likeButton.setImage(defaultLikeImage, for: .normal)
  }
  
}

extension ImageCell {
  
  func configureAsHomeCell(model: ImageViewModel) {
    self.model = model
    self.imageView.setImage(urlSource: model.imageURL)
    self.memoLabel.text =  model.memo
    if model.isLiked == true {
      setLikeButtonToOn()
    }else {
      setLikeButtonToUndoLike()
    }
  }
  
  func configureAsSaveCell(model: ImageViewModel) {
    self.model = model
    self.imageView.setImage(urlSource: model.imageURL)
    setLikeButtonToOn()
    self.memoLabel.text = model.memo
  }
  
  func setLikeButtonToOn() {
    likeButton.setImage(likeImage, for: .normal)
  }
  
}
