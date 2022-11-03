//
//  ViewController.swift
//  Picterest
//

import UIKit
import CloudKit

class HomeViewController: UIViewController {
  
  var viewModel: HomeViewModel
  let layoutProvider = SceneLayout(scene: .home, cellPadding: 6)
  private var isLoading = false
  private var loadingView: Footer?
  private var alertController: UIAlertController?
  
  deinit {
    print("deinit!")
  }
  
  init(viewModel: HomeViewModel) {
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
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    bindErrorMessage()
    setDataBinding()
    setConstraints()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    fetchImage()
  }
  
  //TODO: Implement Scroll down to refresh.
  
}

private extension HomeViewController {
  
  func updateData() {
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
          DispatchQueue.main.async {
            let indexPathArray = self.makeIndexPathArray(list: list.count)
            self.collectionView.performBatchUpdates {
              self.collectionView.insertItems(at: indexPathArray)
            }
        }
    })

  }
  
  func makeIndexPathArray(list: Int) -> [IndexPath] {
    guard list > self.collectionView.numberOfItems(inSection: 0) else {return []}
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

extension HomeViewController: UICollectionViewDataSource, SceneLayoutDelegate, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let count = viewModel.items.value.count
    return count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.id, for: indexPath) as? ImageCell,
          let image = viewModel[indexPath] else { return UICollectionViewCell()}
    if let viewModel = viewModel.items.value[image] {
      cell.updateViewModel(viewModel: viewModel)
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didReceiveToogleLikeStatus(on: indexPath)

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
