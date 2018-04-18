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
    @IBOutlet var resetButton: NSButton!
    var fromWellsArray = [NSColorWell]()
    var toWellsArray = [NSColorWell]()
    let defaults = DefaultsHandler()


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // initialize from/to wells arrays either fresh or from user defaults
        let savedFromDict = defaults.getFromArray()
        let savedToDict = defaults.getToArray()
        let numRows = defaults.getNumRows()
        for i in 0..<numRows {
            var wellFrom: NSColorWell
            var wellTo: NSColorWell
            if (savedFromDict == nil) {
                wellFrom = getRedWell()
                wellTo = getRedWell()
            }
            else {
                wellFrom = (savedFromDict?[i])!
                wellTo = (savedToDict?[i])!
            }
            fromWellsArray.append(wellFrom)
            toWellsArray.append(wellTo)
        }
        defaults.setFromArray(data: fromWellsArray)
        defaults.setToArray(data: toWellsArray)
        
        // Do view setup here.
    }
    
    func getRedWell() -> NSColorWell {
        let well = NSColorWell()
        well.color = NSColor.red
        return well
    }
    
    func saveColors() {
        for (i, colorWell) in fromWellsArray.enumerated() {
            var currentDict = defaults.getFromArray()
            currentDict![i] = colorWell
            defaults.setFromArray(data: currentDict!)
        }
        for (i, colorWell) in toWellsArray.enumerated() {
            var currentDict = defaults.getToArray()
            currentDict![i] = colorWell
            defaults.setToArray(data: currentDict!)
        }
    }
    @IBAction func saveButtonPressed(sender: AnyObject) {
        saveColors()
        dismissViewController(self)
    }
    @IBAction func addRowPressed(sender: NSButton) {
        let numRows = defaults.getNumRows()
        fromWellsArray.append(getRedWell())
        toWellsArray.append(getRedWell())
        defaults.setFromArray(data: fromWellsArray)
        defaults.setToArray(data: toWellsArray)
        tableView.beginUpdates()
        tableView.insertRows(at: IndexSet(integer: numRows), withAnimation: .slideUp)
        tableView.endUpdates()
    }
    
    @IBAction func resetButtonPressed(sender: NSButton) {
        let numRows = defaults.getNumRows()
        for _ in 0..<numRows {
            tableView.removeRows(at: IndexSet(integer: 0), withAnimation: .slideDown)
        }
        fromWellsArray.removeAll()
        toWellsArray.removeAll()
        
        let wellFrom = getRedWell()
        let wellTo = getRedWell()
        fromWellsArray.append(wellFrom)
        toWellsArray.append(wellTo)
        tableView.insertRows(at: IndexSet(integer:0), withAnimation: .slideUp)
        defaults.setFromArray(data: fromWellsArray)
        defaults.setToArray(data: toWellsArray)
    }
    
    func deletePressed(sender: NSButton) {
        // remove from wells arrays 
        let rowToDelete = tableView.row(for: sender)
        fromWellsArray.remove(at: rowToDelete)
        toWellsArray.remove(at: rowToDelete)

        defaults.setFromArray(data: fromWellsArray)
        defaults.setToArray(data: toWellsArray)

        tableView.beginUpdates()
        tableView.removeRows(at: IndexSet(integer: rowToDelete), withAnimation: .slideDown)
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cell = NSView()
        
        if tableColumn?.identifier == "Delete" {
            let deleteButton = NSButton()
            deleteButton.title = "x"
            deleteButton.action = #selector(self.deletePressed)
            cell.addSubview(deleteButton)
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                deleteButton.heightAnchor.constraint(equalToConstant: 20),
                deleteButton.widthAnchor.constraint(equalToConstant: 20),
                deleteButton.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                deleteButton.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
                ])
        }
        
        else if tableColumn?.identifier == "From" || tableColumn?.identifier == "To" {
            var well: NSColorWell = NSColorWell()
            if tableColumn?.identifier == "From" {
                well = fromWellsArray[row]
            }
            else if tableColumn?.identifier == "To" {
                well = toWellsArray[row]
            }
            well.action = #selector(self.colorChanged)
            cell.addSubview(well)
            well.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cell.leftAnchor.constraint(equalTo: well.leftAnchor),
                cell.topAnchor.constraint(equalTo: well.topAnchor),
                cell.bottomAnchor.constraint(equalTo: well.bottomAnchor),
                well.widthAnchor.constraint(equalToConstant: 50)
                ])
        }
        else if tableColumn?.identifier == "FromColor" {
            let well = fromWellsArray[row]
            let newCell = tableView.view(atColumn: 1, row: row, makeIfNecessary: true)
            if newCell == nil {
                setColorNameView(cell: cell, colorName: colorIn(well: well))
            }
            else {
                setColorNameView(cell: newCell!, colorName: colorIn(well: well))
                cell = newCell!
            }
        }
        else if tableColumn?.identifier == "ToColor" {
            let well = toWellsArray[row]
            let newCell = tableView.view(atColumn: 3, row: row, makeIfNecessary: true)
            if newCell == nil {
                setColorNameView(cell: cell, colorName: colorIn(well: well))
            }
            else {
                setColorNameView(cell: newCell!, colorName: colorIn(well: well))
                cell = newCell!
            }
        }
        return cell
    }
    
    func colorChanged(sender: NSColorWell) {
        let colorName = colorIn(well: sender)
        let row = tableView.row(for: sender)
        let col = tableView.column(for: sender)
        let cell = tableView.view(atColumn: col + 1, row: row, makeIfNecessary: true)!
        setColorNameView(cell: cell, colorName: colorName)
    }
    func setColorNameView(cell: NSView, colorName: String) {
        let text = NSTextField()
        let attributedString = NSAttributedString(string: colorName, attributes: ["Color": NSColor.black])
        text.placeholderAttributedString = attributedString
        text.isBordered = false
        cell.addSubview(text)
        text.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cell.leftAnchor.constraint(equalTo: text.leftAnchor),
            cell.topAnchor.constraint(equalTo: text.topAnchor),
            cell.bottomAnchor.constraint(equalTo: text.bottomAnchor),
            text.widthAnchor.constraint(equalToConstant: 50)
            ])
    }
    func colorIn(well: NSColorWell) -> String {
        let color = well.color
        var ptrFrom:CGFloat = 0.0
        color.getHue(&ptrFrom, saturation: nil, brightness: nil, alpha: nil)
        let centerHueAngle: Float = Float(ptrFrom)
        
        if centerHueAngle > 0.97 || centerHueAngle <= 0.04 {
            return "Red"
        }
        else if centerHueAngle <= 0.09 {
            return "Orange"
        }
        else if centerHueAngle <= 0.18 {
            return "Yellow"
        }
        else if centerHueAngle <= 0.4 {
            return "Green"
        }
        else if centerHueAngle <= 0.64 {
            return "Blue"
        }
        else if centerHueAngle <= 0.78 {
            return "Purple"
        }
        else {
            return "Pink"
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        let num = defaults.getNumRows()
        return num
    }
}
