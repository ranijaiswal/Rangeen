//
//  DefaultsHandler.swift
//  Rangeen
//
//  Created by Rani Jaiswal on 4/12/18.
//  Copyright © 2018 Rani Jaiswal. All rights reserved.
//

import Cocoa

class DefaultsHandler {
    func getFromArray() -> [NSColorWell]? {
        let currentFromData = UserDefaults.standard.data(forKey: "fromWellsArray")
        if currentFromData == nil {
            return nil
        }
        let currentFromDict = NSKeyedUnarchiver.unarchiveObject(with: currentFromData!) as? [NSColorWell]
        return currentFromDict
    }
    func getToArray() -> [NSColorWell]? {
        let currentToData = UserDefaults.standard.data(forKey: "toWellsArray")
        if currentToData == nil {
            return nil
        }
        let currentToDict = NSKeyedUnarchiver.unarchiveObject(with: currentToData!) as? [NSColorWell]
        return currentToDict
    }
    
    func setFromArray(data: [NSColorWell]) {
        let fromData = NSKeyedArchiver.archivedData(withRootObject: data) as NSData?
        UserDefaults.standard.set(fromData, forKey: "fromWellsArray")
    }
    func setToArray(data: [NSColorWell]) {
        let toData = NSKeyedArchiver.archivedData(withRootObject: data) as NSData?
        UserDefaults.standard.set(toData, forKey: "toWellsArray")
    }
    
    func getNumRows() -> Int {
        let from = getFromArray()
        if (from != nil) {
            return from!.count
        }
        else {
            return 1
        }
    }
}
