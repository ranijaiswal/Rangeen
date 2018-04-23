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
    @IBOutlet var cancelButton: NSButton!
    
    var colorPairArray = [ColorPair]()
    let defaults = DefaultsHandler()
    var colorPairArrayCache = [ColorPair]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // initialize colorPair arrays either fresh or from user defaults
        
        let savedColorPairs = defaults.getColorPairArray()
        let numRows = defaults.getNumRows()
        for i in 0..<numRows {
            var colorPair: ColorPair
            if (savedColorPairs == nil) {
                colorPair = ColorPair(from: NSColor.red, to: NSColor.red)
            }
            else {
                colorPair = (savedColorPairs?[i])!
            }
            colorPairArray.append(colorPair)
        }
        defaults.setColorPairArray(data: colorPairArray)
        colorPairArrayCache = colorPairArray
        // Do view setup here.
    }
    
    func getRedWell() -> NSColorWell {
        let well = NSColorWell()
        well.color = NSColor.red
        return well
    }
    
    func saveColors() {
        for (i, color) in colorPairArray.enumerated() {
            var currentPairs = defaults.getColorPairArray()
            currentPairs?[i] = color
            defaults.setColorPairArray(data: currentPairs!)
        }
    }
    @IBAction func saveButtonPressed(sender: AnyObject) {
        saveColors()
        dismissViewController(self)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        
        let alert = NSAlert()
        alert.messageText = "Are you sure?"
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        alert.informativeText = "Would you like to discard your changes and go back to your last saved color selections?"
        
        if alert.runModal() == NSAlertFirstButtonReturn {
            dismissViewController(self)
        }
    }
    
    @IBAction func addRowPressed(sender: NSButton) {
        let numRows = defaults.getNumRows()
        colorPairArray.append(ColorPair(from: NSColor.red, to: NSColor.red))
        defaults.setColorPairArray(data: colorPairArray)
        tableView.beginUpdates()
        tableView.insertRows(at: IndexSet(integer: numRows), withAnimation: .slideUp)
        tableView.endUpdates()
    }
    
    @IBAction func resetButtonPressed(sender: NSButton) {
        let alert = NSAlert()
        alert.messageText = "Are you sure?"
        alert.addButton(withTitle: "Continue")
        alert.addButton(withTitle: "Cancel")
        alert.informativeText = "If you would like to remove your color selections, click Continue."
        
        if alert.runModal() == NSAlertFirstButtonReturn {
            resetTable()
        }
        
    }
    func resetTable() {
        let numRows = defaults.getNumRows()
        for _ in 0..<numRows {
            tableView.removeRows(at: IndexSet(integer: 0), withAnimation: .slideDown)
        }
        colorPairArray.removeAll()
        colorPairArray.append(ColorPair(from: NSColor.red, to: NSColor.red))
        tableView.insertRows(at: IndexSet(integer:0), withAnimation: .slideUp)
        defaults.setColorPairArray(data: colorPairArray)
    }
    func deletePressed(sender: NSButton) {
        // remove from wells arrays 
        let rowToDelete = tableView.row(for: sender)
        colorPairArray.remove(at: rowToDelete)
        defaults.setColorPairArray(data: colorPairArray)

        tableView.beginUpdates()
        tableView.removeRows(at: IndexSet(integer: rowToDelete), withAnimation: .slideDown)
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cell = NSView()
        
        if tableColumn?.identifier == "Delete" {
            let deleteButton = NSButton()
            deleteButton.bezelStyle = NSRoundedBezelStyle
            deleteButton.title = "Delete"
            deleteButton.action = #selector(self.deletePressed)
            cell.addSubview(deleteButton)
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                deleteButton.heightAnchor.constraint(equalToConstant: 20),
                deleteButton.widthAnchor.constraint(equalToConstant: 60),
                deleteButton.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                deleteButton.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
                ])
        }
        
        else if tableColumn?.identifier == "From" || tableColumn?.identifier == "To" {
            var color: NSColor = NSColor.red // dummy initialization
            if tableColumn?.identifier == "From" {
                color = colorPairArray[row].from
            }
            else if tableColumn?.identifier == "To" {
                color = colorPairArray[row].to
            }
            let well = NSColorWell()
            well.color = color
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
            let color = colorPairArray[row].from
            let newCell = tableView.view(atColumn: 1, row: row, makeIfNecessary: true)
            if newCell == nil {
                setColorNameView(cell: cell, colorName: NSColorToName(color: color))
            }
            else {
                setColorNameView(cell: newCell!, colorName: NSColorToName(color: color))
                cell = newCell!
            }
        }
        else if tableColumn?.identifier == "ToColor" {
            let color = colorPairArray[row].to
            let newCell = tableView.view(atColumn: 3, row: row, makeIfNecessary: true)
            if newCell == nil {
                setColorNameView(cell: cell, colorName: NSColorToName(color: color))
            }
            else {
                setColorNameView(cell: newCell!, colorName: NSColorToName(color: color))
                cell = newCell!
            }
        }
        return cell
    }
    
    func colorChanged(sender: NSColorWell) {
        let colorName = NSColorToName(color: sender.color)
        let row = tableView.row(for: sender)
        let col = tableView.column(for: sender)
        let currentPair = colorPairArray[row]
        if col == 0 {
            currentPair.from = sender.color
        }
        else if col == 2 {
            currentPair.to = sender.color
        }
        colorPairArray[row] = currentPair
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
    func NSColorToName(color: NSColor) -> String {
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
