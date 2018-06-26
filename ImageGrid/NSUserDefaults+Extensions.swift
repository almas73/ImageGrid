//
//  NSUserDefaults+Extensions.swift
//  ImageGrid
//
//  Created by Almas Daumov on 5/14/16.
//  Copyright © 2016 Almas Daumov. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    enum Keys: String {
        case numberOfColumns
    }
    
    static func numberOfColumns() -> Int {
        let storedNumber = UserDefaults.standard.integer(forKey: Keys.numberOfColumns.rawValue)
        return storedNumber == 0 ? 3 : storedNumber
    }

    static func setNumberOfColumns(_ numberOfColumns: Int) {
        UserDefaults.standard.set(numberOfColumns, forKey: Keys.numberOfColumns.rawValue)
        UserDefaults.standard.synchronize()
    }
}
