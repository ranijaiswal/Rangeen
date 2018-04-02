//
//  SetColors.swift
//  Rangeen
//
//  Created by Rani Jaiswal on 3/29/18.
//  Copyright © 2018 Rani Jaiswal. All rights reserved.
//

import Cocoa

class SetColors: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var colorPickerFrom: NSColorWell!
    @IBOutlet var colorPickerTo: NSColorWell!
    @IBOutlet var saveButton: NSButton!
    @IBOutlet var tableView: NSTableView!
    var colorReplacementFrom = [Int:NSColor]()
    var colorReplacementTo = [Int:NSColor]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        UserDefaults.standard.set(colorReplacementFrom, forKey: "colorReplacementFrom")
        UserDefaults.standard.set(colorReplacementTo, forKey: "colorReplacementTo")

        // Do view setup here.
    }
    @IBAction func cellFromEdited(sender: AnyObject) {
        let well = sender as! NSColorWell
        let index = tableView.selectedRow
        let colorFrom = well.color
        var currentDict = UserDefaults.standard.dictionary(forKey: "colorReplacementFrom")
        currentDict?[String(index)] = colorFrom
        UserDefaults.standard.set(currentDict, forKey: "colorReplacementFrom")
    }
    @IBAction func cellToEdited(sender: AnyObject) {
        let well = sender as! NSColorWell
        let index = tableView.selectedRow
        let colorTo = well.color
        var currentDict = UserDefaults.standard.dictionary(forKey: "colorReplacementTo")
        currentDict?[String(index)] = colorTo
        UserDefaults.standard.set(currentDict, forKey: "colorReplacementTo")
    }
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 3
    }
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return 1
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        // update defaults
        //updateColorCube(colorFrom: colorPickerFrom.color, colorTo: colorPickerTo.color)
        dismissViewController(self)
    }
}
