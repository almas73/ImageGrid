//
//  ViewController.swift
//  ImageGrid
//
//  Created by Almas Daumov on 5/10/16.
//  Copyright © 2016 Almas Daumov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet var collectionView: UICollectionView!
  fileprivate var pinchGestureRecognizer: UIPinchGestureRecognizer!
  fileprivate var longPressGestureRecognizer: UILongPressGestureRecognizer!
  
  // Layout configuration
  fileprivate var numberOfColumns = UserDefaults.numberOfColumns()
  fileprivate let itemPadding: CGFloat = 10
  
  var downloadSession: URLSession!
    
    private let imageCount = 21
  
  var images = [UIImage]()

  override func viewDidLoad() {
    super.viewDidLoad()
    addPinchGestureRecognizer()
    addLongPressGestureRecognizer()
    configureGridLayout()
    loadImages()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    let number = UserDefaults.numberOfColumns()
    if number != numberOfColumns {
      numberOfColumns = number
      if let layout = collectionView.collectionViewLayout as? StackableGridLayout {
        layout.unstack()
      }
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    collectionView.collectionViewLayout.invalidateLayout()
  }
  
  private func loadImages() {
    for i in 1...imageCount {
        if let image = UIImage(named: "\(i)") {
            images.append(image)
        }
    }
  }
  
  fileprivate func addPinchGestureRecognizer() {
    pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGestureRecognizer))
    collectionView.addGestureRecognizer(pinchGestureRecognizer)
  }
  
  fileprivate func addLongPressGestureRecognizer() {
    longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureRecognizer))
    collectionView.addGestureRecognizer(longPressGestureRecognizer)
  }
  
  fileprivate func configureGridLayout() {
    if let layout = collectionView?.collectionViewLayout as? StackableGridLayout {
      layout.delegate = self
    }
  }
  
  func handlePinchGestureRecognizer(_ gestureRecognizer: UIPinchGestureRecognizer) {
    
    let progress: CGFloat = 1 - gestureRecognizer.scale
    
    switch gestureRecognizer.state {
    case .began where gestureRecognizer.numberOfTouches == 2:
      if let layout = self.collectionView.collectionViewLayout as? StackableGridLayout {
        let firstPoint = gestureRecognizer.location(ofTouch: 0, in: collectionView)
        let secondPoint = gestureRecognizer.location(ofTouch: 1, in: collectionView)
        let centerPoint = findCenterPoint(firstPoint, second: secondPoint)
        
        guard var firstIndex = collectionView.indexPathForItem(at: firstPoint),
          var lastIndex = collectionView.indexPathForItem(at: secondPoint)
          else { return }
        
        if firstIndex.item > lastIndex.item {
          let temp = firstIndex
          firstIndex = lastIndex
          lastIndex = temp
        }
        
        layout.beginPinchGesture(firstIndex, lastIndex: lastIndex, center: centerPoint, progress: progress)
      }
    case .changed where gestureRecognizer.numberOfTouches == 2:
      if let layout = self.collectionView.collectionViewLayout as? StackableGridLayout {
        let firstPoint = gestureRecognizer.location(ofTouch: 0, in: collectionView)
        let secondPoint = gestureRecognizer.location(ofTouch: 1, in: collectionView)
        let centerPoint = findCenterPoint(firstPoint, second: secondPoint)
        layout.continuePinchGesture(centerPoint, progress: progress)
      }
    case .ended:
      if let layout = self.collectionView.collectionViewLayout as? StackableGridLayout {
        collectionView.performBatchUpdates({
          layout.endPinchGesture()
          }, completion: nil)
      }
    default:
      break
    }
  }
  
  fileprivate func findCenterPoint(_ first: CGPoint, second: CGPoint) -> CGPoint {
    return CGPoint(x: (first.x+second.x)/2, y: (first.y+second.y)/2)
  }
  
  func handleLongPressGestureRecognizer(_ gestureRecognizer: UILongPressGestureRecognizer) {
    switch(gestureRecognizer.state) {
      
    case UIGestureRecognizerState.began:
      guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gestureRecognizer.location(in: collectionView)) else {
        break
      }
      collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
    case UIGestureRecognizerState.changed:
      collectionView.updateInteractiveMovementTargetPosition(gestureRecognizer.location(in: gestureRecognizer.view!))
    case UIGestureRecognizerState.ended:
      collectionView.endInteractiveMovement()
    default:
      collectionView.cancelInteractiveMovement()
    }
  }
}

extension ViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell
    gridCell.imageView.image = images[indexPath.item]
    return gridCell
  }
}

extension ViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    let layout = collectionView.collectionViewLayout as! StackableGridLayout
    return layout.state == .unstacked
  }
  
  func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    if sourceIndexPath.item != destinationIndexPath.item {
      let image = images.remove(at: sourceIndexPath.item)
      images.insert(image, at: destinationIndexPath.item)
     
      collectionView.performBatchUpdates({
        collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
  }
}

extension ViewController: GridLayoutDelegate {
  
  func numberOfColumnsInCollectionView(_ collectionView: UICollectionView) -> Int {
    return numberOfColumns
  }
  
  func itemPaddingInCollectionView(_ collectionView: UICollectionView) -> CGFloat {
    return itemPadding
  }
  
  func collectionView(_ collecitionView: UICollectionView, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
    let image = images[indexPath.item]
    let width = (collectionView.bounds.width - (itemPadding * CGFloat(numberOfColumns + 1))) / CGFloat(numberOfColumns)
    let imageSideOffset = CGFloat(10) // left+right | top+buttom in storyboard
    let height = (image.size.height / image.size.width * (width - imageSideOffset))
    return CGSize(width: width, height: height + imageSideOffset)
  }
  
}
