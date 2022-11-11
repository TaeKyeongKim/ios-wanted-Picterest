//
//  ImageCell.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/25.
//

import UIKit

final class ImageCell: UICollectionViewCell {
  
  static let id = "ImageCell"
  private var viewModel: ImageViewModel? {
    didSet{
      guard let viewModel = viewModel else {
        return
      }

      self.memoLabel.text =  viewModel.memo
      if viewModel.isLiked == true {
        setLikeButtonToOn()
      }else {
        setLikeButtonToUndoLike()
      }
    }
  }
  
  var saveDidTap: ((ImageViewModel) -> Void)?
  private var isLiked: Bool?

  
  private let likeStateImage: UIImage? = {
    let image = UIImage(systemName: "star.fill")
    return image
  }()
  
  private let unlikeStateImage: UIImage? = {
    let image = UIImage(systemName: "star")
    return image
  }()
  
  private lazy var likeImage: UIImageView = {
    var imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.image = unlikeStateImage
    imageView.tintColor = UIColor(red: 0.9882352941, green: 0.7607843137, blue: 0, alpha: 1)
    return imageView
  }()
  
  private let memoLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.backgroundColor = .clear
    label.font = .systemFont(ofSize: 17, weight: .medium)
    return label
  }()
  
  private lazy var labelStackView: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [likeImage, memoLabel])
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

  private func setLikeButtonToUndoLike() {
    likeImage.image = unlikeStateImage
  }
  
  private func setLikeButtonToOn() {
    likeImage.image = likeStateImage
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
    likeImage.image = unlikeStateImage
  }
  
}

extension ImageCell {
  
  func updateViewModel(viewModel: ImageViewModel, thumnbnailImageRepository: ThumbnailImagesRepository) {
    self.viewModel = viewModel
    thumnbnailImageRepository.fetchImageData(with: viewModel.imageURL) { result in
      switch result {
      case .success(let data):
        DispatchQueue.main.async {
          self.imageView.image = UIImage(data: data)
        }
      case .failure(let error):
        print(error.localizedDescription)
      }
    }
    
  }
}
