//
//  SettingsViewController.swift
//  ImageGrid
//
//  Created by Almas Daumov on 5/14/16.
//  Copyright © 2016 Almas Daumov. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
  
  @IBOutlet fileprivate var segmentedControl: UISegmentedControl!

  override func viewDidLoad() {
    super.viewDidLoad()
    segmentedControl.selectedSegmentIndex = UserDefaults.numberOfColumns() - 1
  }

  @IBAction fileprivate func segmentedControlValueDidChange(_ control: UISegmentedControl) {
    UserDefaults.setNumberOfColumns(control.selectedSegmentIndex + 1)
  }

}
