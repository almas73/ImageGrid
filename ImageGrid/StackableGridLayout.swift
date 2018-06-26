//
//  StackableGridLayout.swift
//  ImageGrid
//
//  Created by Almas Daumov on 5/15/16.
//  Copyright © 2016 Almas Daumov. All rights reserved.
//

import UIKit

class StackableGridLayout: GridLayout {
  
  enum GridLayoutState {
    case unstacked
    case stacking
    case stacked
    case unstacking
  }
  
  // Stacking
  fileprivate (set) var state: GridLayoutState = .unstacked
  fileprivate var stackingCenter = CGPoint.zero
  fileprivate var stackingProgress: CGFloat = 0
  fileprivate var stackedIndexes: [Int] = [Int]()
  
  override func prepare() {
    super.prepare()
    doStacking()
  }
  
  fileprivate func doStacking() {
    if stackedIndexes.isEmpty {
      return
    }
    
    var z = 0
    var angle: CGFloat = 0
    
    for attributeIndex in stackedIndexes {
      let attributes = cachedAttributes[attributeIndex]
      
      // cell center
      var newCenter = CGPoint.zero
      newCenter.x = attributes.center.x + (stackingCenter.x - attributes.center.x) * stackingProgress
      newCenter.y = attributes.center.y + (stackingCenter.y - attributes.center.y) * stackingProgress
      attributes.center = newCenter
      
      // rotation
      attributes.transform = CGAffineTransform.identity.rotated(by: degreesToRadians(angle) * stackingProgress)
      angle = angle + 15
      
      // alpha
      if attributeIndex != stackedIndexes.last {
        attributes.alpha = 1 - stackingProgress * 0.3
      }
      
      // zIndex
      attributes.zIndex = z
      z = z + 1
    }
  }
  
  fileprivate func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
    return degrees / 180.0 * CGFloat(Double.pi)
  }
}

//MARK: - Public interface
extension StackableGridLayout {
  
  func beginPinchGesture(_ firstIndex: IndexPath, lastIndex: IndexPath, center: CGPoint, progress: CGFloat) {
    if state == .unstacked {
      beginStacking(firstIndex, lastIndex: lastIndex, center: center, progress: progress)
    }
    else if state == .stacked {
      if stackedIndexes.contains(firstIndex.item) && stackedIndexes.contains(lastIndex.item) {
        beginUnstacking(firstIndex, lastIndex: lastIndex, center: center, progress: progress)
      }
    }
  }
  
  func continuePinchGesture(_ center: CGPoint, progress: CGFloat) {
    if state == .stacking {
      continueStacking(center, progress: progress)
    }
    else if state == .unstacking {
      continueUnstacking(center, progress: progress)
    }
  }
  
  func endPinchGesture() {
    if state == .stacking {
      if stackingProgress < 0.5 {
        cancelStacking()
      }
      else {
        finishStacking()
      }
    }
    else if state == .unstacking {
      if stackingProgress < 0.5 {
        cancelStacking()
      }
      else {
        finishStacking()
      }
    }
  }
  
  func unstack() {
    cancelStacking()
  }
}

//MARK: - Private
extension StackableGridLayout {
  fileprivate func beginStacking(_ firstIndex: IndexPath, lastIndex: IndexPath, center: CGPoint, progress: CGFloat) {
    
    state = .stacking
    
    stackingCenter = center
    stackingProgress = 0
    stackedIndexes.removeAll()
    
    for i in firstIndex.item...lastIndex.item {
      stackedIndexes.append(i)
    }
    
    invalidateLayout()
  }
  
  fileprivate func continueStacking(_ center: CGPoint, progress: CGFloat) {
    stackingCenter = center
    
    if progress < 0 && stackingProgress == 0 {
      return
    }
    
    stackingProgress = progress < 0 ? 0 : progress
    invalidateLayout()
  }
  
  fileprivate func beginUnstacking(_ firstIndex: IndexPath, lastIndex: IndexPath, center: CGPoint, progress: CGFloat) {
    state = .unstacking
    
    stackingProgress = 1
    stackingCenter = center
    invalidateLayout()
  }
  
  fileprivate func continueUnstacking(_ center: CGPoint, progress: CGFloat) {
    
    stackingCenter = center
    
    stackingProgress = 1 + progress
    if stackingProgress < 0 {
      stackingProgress = 0
    }
    if stackingProgress > 1 {
      stackingProgress = 1
    }
    invalidateLayout()
  }
  
  fileprivate func cancelStacking() {
    state = .unstacked
    stackedIndexes.removeAll()
    cachedAttributes.removeAll()
    invalidateLayout()
  }
  
  fileprivate func finishStacking() {
    state = .stacked
    stackingProgress = 1
    invalidateLayout()
  }
}


//MARK: - Reordering
extension StackableGridLayout {
  
  override func invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths indexPaths: [IndexPath],
                                                                       previousIndexPaths: [IndexPath],
                                                                       movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext {
    delegate?.collectionView!(collectionView!, moveItemAt: previousIndexPaths[0], to: indexPaths[0])
    return super.invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths: indexPaths,
                                                                        previousIndexPaths: previousIndexPaths,
                                                                        movementCancelled: movementCancelled)
  }
  
}
