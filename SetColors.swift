//
//  SetColors.swift
//  Rangeen
//
//  Created by Rani Jaiswal on 3/29/18.
//  Copyright © 2018 Rani Jaiswal. All rights reserved.
//

import Cocoa

class SetColors: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var saveButton: NSButton!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var addRowsButton: NSButton!
   // var colorReplacementFrom = [Int:NSColor]()
   // var colorReplacementTo = [Int:NSColor]()
    var numRows: Int = 2
    var fromWellsArray = [String: NSColorWell]()
    var toWellsArray = [String: NSColorWell]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let currentFromData = UserDefaults.standard.data(forKey: "fromWellsArray")
        let currentFromDict = NSKeyedUnarchiver.unarchiveObject(with: currentFromData!) as? [String: NSColorWell]
        let currentToData = UserDefaults.standard.data(forKey: "toWellsArray")
        let currentToDict = NSKeyedUnarchiver.unarchiveObject(with: currentToData!) as? [String: NSColorWell]
        for i in 0..<numRows {
            var wellFrom: NSColorWell
            var wellTo: NSColorWell
            if (currentFromDict == nil) {
                wellFrom = NSColorWell()
                wellTo = NSColorWell()
                wellFrom.color = NSColor.red
                wellTo.color = NSColor.red
                wellFrom.identifier = String(i)
                wellTo.identifier = String(i)
            }
            else {
                wellFrom = (currentFromDict?[String(i)])!
                wellTo = (currentToDict?[String(i)])!
            }
            fromWellsArray[String(i)] = wellFrom
            toWellsArray[String(i)] = wellTo
        }
        let fromData = NSKeyedArchiver.archivedData(withRootObject: fromWellsArray) as NSData?
        let toData = NSKeyedArchiver.archivedData(withRootObject: toWellsArray) as NSData?
        UserDefaults.standard.set(fromData, forKey: "fromWellsArray")
        UserDefaults.standard.set(toData, forKey: "toWellsArray")
        // Do view setup here.
    }
    
    // when cell is edited, updates in defaults
    func cellFromEdited(well: NSColorWell) {
        let index = Int(well.identifier!)!
        if index >= 0 {
            let currentDictData = UserDefaults.standard.data(forKey: "fromWellsArray")!
            var currentDict = NSKeyedUnarchiver.unarchiveObject(with: currentDictData) as? [String: NSColorWell]
            currentDict![well.identifier!] = well
            let currentDictNSData = NSKeyedArchiver.archivedData(withRootObject: currentDict!) as NSData?
            UserDefaults.standard.set(currentDictNSData, forKey: "lastCubeFilter")
            UserDefaults.standard.set(currentDictNSData, forKey: "fromWellsArray")
        }
    }
    func cellToEdited(well: NSColorWell) {
        let index = Int(well.identifier!)!
        if index >= 0 {
            let currentDictData = UserDefaults.standard.data(forKey: "toWellsArray")!
            var currentDict = NSKeyedUnarchiver.unarchiveObject(with: currentDictData) as? [String: NSColorWell]
            currentDict![well.identifier!] = well
            let currentDictNSData = NSKeyedArchiver.archivedData(withRootObject: currentDict!) as NSData?
            UserDefaults.standard.set(currentDictNSData, forKey: "lastCubeFilter")
            UserDefaults.standard.set(currentDictNSData, forKey: "toWellsArray")
        }
    }
    
    func updateColors() {
        for colorWell in fromWellsArray.values {
            cellFromEdited(well: colorWell)
        }
        for colorWell in toWellsArray.values {
            cellToEdited(well: colorWell)
        }
    }
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return numRows
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = NSTableCellView()
        var well: NSColorWell = NSColorWell()
        if tableColumn?.identifier == "From" {
            well = fromWellsArray[String(row)]!
        }
        else if tableColumn?.identifier == "To" {
            well = toWellsArray[String(row)]!
        }
        cell.addSubview(well)
        well.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cell.leftAnchor.constraint(equalTo: well.leftAnchor),
            cell.topAnchor.constraint(equalTo: well.topAnchor),
            cell.bottomAnchor.constraint(equalTo: well.bottomAnchor),
            well.widthAnchor.constraint(equalToConstant: 50)
        ])
        return cell
        
    }
    @IBAction func addRowPressed(sender: NSButton) {
        tableView.beginUpdates()
        tableView.insertRows(at: IndexSet(integer: numRows), withAnimation: .effectFade)
        tableView.endUpdates()
        numRows += 1
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        updateColors()
        dismissViewController(self)
    }
}
