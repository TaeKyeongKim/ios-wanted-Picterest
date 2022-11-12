//
//  SaveViewController.swift
//  Picterest
//
//  Created by Kai Kim on 2022/07/28.
//

import UIKit

class SaveViewController: UIViewController {
  let viewModel: SaveViewModel
  let collectionViewCustomLayout: CustomLayout
  private let thumbnailImageRepository: ThumbnailImagesRepository
  
  init(viewModel: SaveViewModel,
       thumbnailImageRepository: ThumbnailImagesRepository,
       collectionViewCustomLayout: CustomLayout) {
    self.viewModel = viewModel
    self.thumbnailImageRepository = thumbnailImageRepository
    self.collectionViewCustomLayout = collectionViewCustomLayout
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewCustomLayout)
    collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.id)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    return collectionView
  }()
  
  private let defaultView: EmptyIndicatorView = {
    let defaultView = EmptyIndicatorView()
    defaultView.translatesAutoresizingMaskIntoConstraints = false
    return defaultView
  }()

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    fetchImage()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    setGuesture()
    bind(to: viewModel)
    setConstraints()
  }
  
}

private extension SaveViewController {

  func fetchImage() {
    viewModel.fetchImage()
  }
  
  func bind(to viewModel: SaveViewModel) {
    viewModel.items.bind({ [weak self] _ in
      self?.updateItems()
    })
    viewModel.error.bind({ [weak self] in self?.showError($0)})
  }

  func updateItems() {
    DispatchQueue.main.async {
      if self.viewModel.items.value.isEmpty {
        self.defaultView.isHidden = false
      }else {
        self.defaultView.isHidden = true
      }
      self.collectionView.performBatchUpdates {
        self.collectionView.reloadSections(IndexSet(integer: 0))
      }
    }
  }
  
  func showError(_ error: String) {
    guard !error.isEmpty else { return }
    print(error)
  }
  
  func setConstraints() {
    view.addSubview(collectionView)
    view.addSubview(defaultView)
    
    if let layout = collectionView.collectionViewLayout as? CustomLayout {
      layout.delegate = self
    }
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      
      defaultView.topAnchor.constraint(equalTo: collectionView.topAnchor),
      defaultView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor),
      defaultView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
      defaultView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor)
    ])
  }
    
  func setGuesture() {
    let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                           action: #selector(handleLongPress))
    lpgr.minimumPressDuration = 0.5
    lpgr.delegate = self
    lpgr.delaysTouchesBegan = true
    self.collectionView.addGestureRecognizer(lpgr)
  }
  
  @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
    if gestureRecognizer.state == .began {
      let selectedLocation = gestureRecognizer.location(in: self.collectionView)
      if let indexPath = self.collectionView.indexPathForItem(at: selectedLocation) {
        guard let model = viewModel[indexPath] else {return}
        handleAlert(model)
      } else {
        print("couldn't find index path")
      }
    }
  }
  
  func handleAlert(_ model: Image) {
    guard let memo = model.memo else {return}
    _ = MemoAlert.makeAlertController(title: nil,
                                      message: "선택하신 메모 '\(memo)' 를 지우시겠습니까?",
                                      actions: .ok({ _ in
      self.viewModel.didUnLikeImage(model){_ in }
    }), .cancel, from: self)
  }
  
}

extension SaveViewController: UICollectionViewDataSource, CustomLayoutDelegate, UIGestureRecognizerDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let count = viewModel.items.value.count
    return count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.id, for: indexPath) as? ImageCell
    else {
      return UICollectionViewCell()
    }
    let viewModel = viewModel.items.value[indexPath.item]
    cell.updateViewModel(viewModel: viewModel, thumnbnailImageRepository: thumbnailImageRepository)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSetWidthRatioAt indexPath: IndexPath) -> CGFloat {
    guard let image = viewModel[indexPath] else {return 0}
    return CGFloat(image.width) / CGFloat(image.height)
  }

}
