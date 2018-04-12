//
//  DefaultsHandler.swift
//  Rangeen
//
//  Created by Rani Jaiswal on 4/12/18.
//  Copyright © 2018 Rani Jaiswal. All rights reserved.
//

import Cocoa

class DefaultsHandler {
    func getFromArray() -> [String:NSColorWell]? {
        let currentFromData = UserDefaults.standard.data(forKey: "fromWellsArray")
        let currentFromDict = NSKeyedUnarchiver.unarchiveObject(with: currentFromData!) as? [String: NSColorWell]
        return currentFromDict
    }
    func getToArray() -> [String:NSColorWell]? {
        let currentToData = UserDefaults.standard.data(forKey: "toWellsArray")
        let currentToDict = NSKeyedUnarchiver.unarchiveObject(with: currentToData!) as? [String: NSColorWell]
        return currentToDict
    }
    
    func setFromArray(data: [String:NSColorWell]) {
        let fromData = NSKeyedArchiver.archivedData(withRootObject: data) as NSData?
        UserDefaults.standard.set(fromData, forKey: "fromWellsArray")
    }
    func setToArray(data: [String:NSColorWell]) {
        let toData = NSKeyedArchiver.archivedData(withRootObject: data) as NSData?
        UserDefaults.standard.set(toData, forKey: "toWellsArray")
    }
}
