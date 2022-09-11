//
//  ViewController.swift
//  Picterest
//

import UIKit

class HomeViewController: UIViewController {
  
  var viewModel: DefaultHomeViewModel
  let layoutProvider = SceneLayout(scene: .home, cellPadding: 6)
  private var isLoading = false
  private var loadingView: Footer?
  private var alertController: UIAlertController?
  
  init(viewModel: DefaultHomeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutProvider)
    collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.id)
    collectionView.register(Footer.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                            withReuseIdentifier: Footer.id)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    return collectionView
  }()
  
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateData()
    fetchImage()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    ImageManager.shared.clearStorage { e in
      print(e?.localizedDescription)
    }
    bindErrorMessage()
    setDataBinding()
    setConstraints()
  }
  

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.viewWillDisappear()
    
  }
  
}

private extension HomeViewController {
  
  func updateData() {
    viewModel.viewWillAppear()
    DispatchQueue.main.async {
      self.collectionView.reloadSections(IndexSet(integer: 0))
    }
  }

  
  func fetchImage() {
    if viewModel.items.value.isEmpty {
      viewModel.didLoadNextPage()
    }
  }
  
  func bindErrorMessage() {
    self.viewModel.error.bind({ errorMessage in
      print(errorMessage)
    })
  }
  
  func setDataBinding() {
    self.viewModel.items.bind({ list in
      let group = DispatchGroup()
      DispatchQueue.global().async {
        if list.count > 0 {
          group.enter()
          DispatchQueue.main.async {
            let indexPathArray = self.makeIndexPathArray(list: list.count)
            self.collectionView.performBatchUpdates {
              self.collectionView.insertItems(at: indexPathArray)
            }
            group.leave()
          }
        }
        group.wait()
      }
    })
  }
  
  func makeIndexPathArray(list: Int) -> [IndexPath] {
    var indexPathArray:[IndexPath] = []
    for i in self.collectionView.numberOfItems(inSection: 0)..<list {
      indexPathArray.append(IndexPath(item: i, section: 0))
    }
    return indexPathArray
  }
  
  
  func setConstraints() {
    view.addSubview(collectionView)
    if let layout = collectionView.collectionViewLayout as? SceneLayout {
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
  
  func didReceiveToogleLikeStatus(on cell: ImageCell) {
    cell.saveDidTap = { selectedImageEntity in
      let alert = MemoAlert.makeAlertController(title: nil,
                                                message: "이미지를 저장 하시겠습니까?",
                                                actions: .ok({
        guard let memo = $0 else {return}
        print("\(memo) is to be saved!")
        self.viewModel.didLikeImage(id: selectedImageEntity.id)
        cell.setLikeButtonToOn()
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

extension HomeViewController: UICollectionViewDataSource, SceneLayoutDelegate, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let count = viewModel.items.value.count
    return count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.id, for: indexPath) as? ImageCell else { return UICollectionViewCell()}
    let viewModel = viewModel.items.value[indexPath.item]
//    print("\(indexPath.item + 1) 번째 이미지는 \(viewModel.isLiked) 상태 입니다.")
    cell.configureAsHomeCell(model: viewModel)
    didReceiveToogleLikeStatus(on: cell)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
    guard let image = viewModel[indexPath] else {return 0}
    let widthRatio = CGFloat(image.width) / CGFloat(image.height)
    return ((view.frame.width / CGFloat(layoutProvider.numberOfColumns)) - layoutProvider.cellPadding * 2) / widthRatio
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let contentOffsetY = scrollView.contentOffset.y
    if contentOffsetY >= (scrollView.contentSize.height - scrollView.bounds.height) - 20 {
      guard !self.isLoading else { return }
      self.isLoading = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        self.viewModel.didLoadNextPage()
        self.isLoading = false
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
