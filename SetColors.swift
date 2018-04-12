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
    var numRows: Int = 2
    var fromWellsArray = [String: NSColorWell]()
    var toWellsArray = [String: NSColorWell]()
    let defaults = DefaultsHandler()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let currentFromDict = defaults.getFromArray()
        let currentToDict = defaults.getToArray()
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
        defaults.setFromArray(data: fromWellsArray)
        defaults.setToArray(data: toWellsArray)
        // Do view setup here.
    }
    
    // when cell is edited, updates in defaults
    func cellFromEdited(well: NSColorWell) {
        let index = Int(well.identifier!)!
        if index >= 0 {
            var currentDict = defaults.getFromArray()
            currentDict![well.identifier!] = well
            defaults.setFromArray(data: currentDict!)
        }
    }
    func cellToEdited(well: NSColorWell) {
        let index = Int(well.identifier!)!
        if index >= 0 {
            var currentDict = defaults.getToArray()
            currentDict![well.identifier!] = well
            defaults.setToArray(data: currentDict!)
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
