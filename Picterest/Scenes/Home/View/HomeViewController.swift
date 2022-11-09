//
//  ViewController.swift
//  Picterest
//

import UIKit

class HomeViewController: UIViewController {
  
  private var isLoading = false
  private var loadingView: Footer?
  private var alertController: UIAlertController?
  let viewModel: HomeViewModel
  let collectionViewCustomLayout: CustomLayout
  private let thumbnailImageRepository: ThumbnailImagesRepository

  init(viewModel: HomeViewModel,
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
    collectionView.register(Footer.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                            withReuseIdentifier: Footer.id)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    return collectionView
  }()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    setConstraints()
    bind(to: viewModel)
    fetchData()
  }
    
}

private extension HomeViewController {
    
  func fetchData() {
    viewModel.fetchData()
  }
  
  func reload() {
    DispatchQueue.main.async {
      self.collectionView.reloadData()
    }
  }
  
  
  func bind(to viewModel: HomeViewModel) {
    viewModel.items.bind({ [weak self] newImages in
      self?.updateItems(currentImageCount: newImages.count)
    })
    viewModel.error.bind({ [weak self] in self?.showError($0)})
  }


  func showError(_ error: String) {
    guard !error.isEmpty else { return }
    print(error)
  }
  

  //15 개의 새로운 image 만 IndexPath 로 만들어서 insert 해주어야함.
  func updateItems(currentImageCount: Int){
    DispatchQueue.main.async { [unowned self] in
      guard currentImageCount >= self.collectionView.numberOfItems(inSection: 0) else {return}
      var indexPathArray:[IndexPath] = []
      for i in self.collectionView.numberOfItems(inSection: 0)..<currentImageCount {
        indexPathArray.append(IndexPath(item: i, section: 0))
      }
      self.collectionView.performBatchUpdates {
        self.collectionView.insertItems(at:indexPathArray)
      }
    }
  }
  
  
  func setConstraints() {
    view.addSubview(collectionView)
    if let layout = collectionView.collectionViewLayout as? CustomLayout {
      layout.delegate = self
    }
    collectionView.delegate = self
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }
  
  func didReceiveToogleLikeStatus(on index: IndexPath) {
      let alert = MemoAlert.makeAlertController(title: nil,
                                                message: "이미지를 저장 하시겠습니까?",
                                                actions: .ok({
        guard let memo = $0 else {return}
        self.viewModel.didLikeImage(itemIndex: index, memo: memo){ result in
          if case .success() = result {
            DispatchQueue.main.async {
              self.collectionView.reloadItems(at: [index])
            }
          }
        }
      }),
                                                .cancel,
                                                from: self)
      alert.addTextField(configurationHandler: {(textField: UITextField) in
        textField.placeholder = "어떤 영감을 받았나요?"
        textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
      })
      alert.actions[0].isEnabled = false
      self.alertController = alert
  }
  
  @objc func textChanged(_ sender:UITextField) {
    guard let alertController = self.alertController else {return}
    if !(sender.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
      alertController.actions[0].isEnabled = true
      MemoAlert.memo = sender.text
    }else {
      alertController.actions[0].isEnabled = false
    }
  }
}

extension HomeViewController: UICollectionViewDataSource, CustomLayoutDelegate, UICollectionViewDelegate {  
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let count = viewModel.items.value.count
    return count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.id, for: indexPath) as? ImageCell
           else { return UICollectionViewCell()}
    let image = viewModel[indexPath]
    if let imageViewModel = viewModel.searchImageViewModel(on: image) { 
      cell.updateViewModel(viewModel: imageViewModel, thumnbnailImageRepository: thumbnailImageRepository)
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didReceiveToogleLikeStatus(on: indexPath)
  }
  
  
  func collectionView(_ collectionView: UICollectionView, didSetWidthRatioAt indexPath: IndexPath) -> CGFloat {
    let imageViewModel = viewModel[indexPath]
    return CGFloat(imageViewModel.width) / CGFloat(imageViewModel.height)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let contentOffsetY = scrollView.contentOffset.y
    if contentOffsetY >= (scrollView.contentSize.height - scrollView.bounds.height) - 20 {
      guard !self.isLoading else { return }
      self.isLoading = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
        self?.viewModel.didLoadNextPage()
        self?.isLoading = false
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: Footer.id, for: indexPath) as? Footer else {
      return UICollectionReusableView()
    }
    loadingView = footer
    loadingView?.activityIndicator.startAnimating()
    return footer
  }
  
}
