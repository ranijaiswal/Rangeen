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
    var colorReplacementFrom = [Int:NSColor]()
    var colorReplacementTo = [Int:NSColor]()
    var numRows: Int = 3
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let fromData = NSKeyedArchiver.archivedData(withRootObject: colorReplacementFrom) as NSData?
        let toData = NSKeyedArchiver.archivedData(withRootObject: colorReplacementTo) as NSData?
        UserDefaults.standard.set(fromData, forKey: "colorReplacementFrom")
        UserDefaults.standard.set(toData, forKey: "colorReplacementTo")
        numRows = 3
        // Do view setup here.
    }
    
    // when cell is edited, updates in defaults
    @IBAction func cellFromEdited(sender: NSColorWell) {
        let well = sender
        let index = tableView.selectedRow
        if index >= 0 {
            let colorFrom = well.color
            let currentDictData = UserDefaults.standard.data(forKey: "colorReplacementFrom")!
            var currentDict = NSKeyedUnarchiver.unarchiveObject(with: currentDictData) as? [Int: NSColor]
            currentDict![index] = colorFrom
            let currentDictNSData = NSKeyedArchiver.archivedData(withRootObject: currentDict!) as NSData?
            UserDefaults.standard.set(currentDictNSData, forKey: "lastCubeFilter")
            UserDefaults.standard.set(currentDictNSData, forKey: "colorReplacementFrom")
        }
    }
    @IBAction func cellToEdited(sender: NSColorWell) {
        let well = sender
        let index = tableView.selectedRow
        if index >= 0 {
            let colorTo = well.color
            let currentDictData = UserDefaults.standard.data(forKey: "colorReplacementTo")!
            var currentDict = NSKeyedUnarchiver.unarchiveObject(with: currentDictData) as? [Int: NSColor]
            currentDict![index] = colorTo
            let currentDictNSData = NSKeyedArchiver.archivedData(withRootObject: currentDict!) as NSData?
            UserDefaults.standard.set(currentDictNSData, forKey: "lastCubeFilter")
            UserDefaults.standard.set(currentDictNSData, forKey: "colorReplacementTo")
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
        let well = NSColorWell()
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
        dismissViewController(self)
    }
}
