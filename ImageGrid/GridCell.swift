//
//  GridCell.swift
//  ImageGrid
//
//  Created by Almas Daumov on 5/10/16.
//  Copyright © 2016 Almas Daumov. All rights reserved.
//

import UIKit

class GridCell: UICollectionViewCell {
  @IBOutlet var imageView: UIImageView!
  
  override func prepareForReuse() {
    super.prepareForReuse()
    imageView.image = nil
  }
}
