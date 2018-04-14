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
    var fromWellsArray = [String: NSColorWell]()
    var toWellsArray = [String: NSColorWell]()
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
                wellFrom = getRedWell(id: String(i))
                wellTo = getRedWell(id: String(i))
            }
            else {
                wellFrom = (savedFromDict?[String(i)])!
                wellTo = (savedToDict?[String(i)])!
            }
            fromWellsArray[String(i)] = wellFrom
            toWellsArray[String(i)] = wellTo
        }
        defaults.setFromArray(data: fromWellsArray)
        defaults.setToArray(data: toWellsArray)
        // Do view setup here.
    }
    
    func getRedWell(id: String) -> NSColorWell {
        let well = NSColorWell()
        well.identifier = id
        well.color = NSColor.red
        return well
    }
    
    func saveColors() {
        for colorWell in fromWellsArray.values {
            var currentDict = defaults.getFromArray()
            currentDict![colorWell.identifier!] = colorWell
            defaults.setFromArray(data: currentDict!)
        }
        for colorWell in toWellsArray.values {
            var currentDict = defaults.getToArray()
            currentDict![colorWell.identifier!] = colorWell
            defaults.setToArray(data: currentDict!)
        }
    }
    @IBAction func saveButtonPressed(sender: AnyObject) {
        saveColors()
        dismissViewController(self)
    }
    @IBAction func addRowPressed(sender: NSButton) {
        let numRows = defaults.getNumRows()
        fromWellsArray[String(numRows)] = getRedWell(id: String(numRows))
        toWellsArray[String(numRows)] = getRedWell(id: String(numRows))
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
        defaults.setFromArray(data: fromWellsArray)
        defaults.setToArray(data: toWellsArray)
    }
    
    func deletePressed(sender: NSButton) {
        // remove from wells arrays 
        let numRows = defaults.getNumRows()
        let rowToDelete = tableView.row(for: sender)
        fromWellsArray.removeValue(forKey: String(rowToDelete))
        toWellsArray.removeValue(forKey: String(rowToDelete))
        let start = rowToDelete + 1
        if (start < numRows) {
            for i in start..<numRows {
                let fromWell = fromWellsArray[String(i)]
                print(tableView.row(for: fromWell!))
                let toWell = toWellsArray[String(i)]
                fromWellsArray.removeValue(forKey: String(i))
                toWellsArray.removeValue(forKey: String(i))
                
                fromWell?.identifier = String(Int((fromWell?.identifier)!)! - 1)
                toWell?.identifier = String(Int((toWell?.identifier)!)! - 1)
                
                fromWellsArray[String(i - 1)] = fromWell
                toWellsArray[String(i - 1)] = toWell
            }
        }

        defaults.setFromArray(data: fromWellsArray)
        defaults.setToArray(data: toWellsArray)

        tableView.beginUpdates()
        tableView.removeRows(at: IndexSet(integer: rowToDelete), withAnimation: .slideDown)
        tableView.endUpdates()
    }
    // tableView inherited methods below
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = NSTableCellView()
        
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
            return cell
        }
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
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        let num = defaults.getNumRows()
        return num
    }
}
