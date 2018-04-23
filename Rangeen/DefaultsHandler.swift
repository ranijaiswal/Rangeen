//
//  DefaultsHandler.swift
//  Rangeen
//
//  Created by Rani Jaiswal on 4/12/18.
//  Copyright © 2018 Rani Jaiswal. All rights reserved.
//

import Cocoa

class DefaultsHandler {
    
    func getColorPairArray() -> [ColorPair]? {
        let currentData = UserDefaults.standard.data(forKey: "colorPairArray")
        if (currentData == nil) {
            return []
        }
        let currentArray = NSKeyedUnarchiver.unarchiveObject(with: currentData!) as? [ColorPair]
        return currentArray
    }
    
    func setColorPairArray(data: [ColorPair]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: data) as NSData?
        UserDefaults.standard.set(data, forKey: "colorPairArray")
    }
    
    func getNumRows() -> Int {
        let from = getColorPairArray()
        if (from != nil) {
            return from!.count
        }
        else {
            return 1
        }
    }
}
