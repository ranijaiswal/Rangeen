//
//  ViewController.swift
//  Rangeen
//
//  Created by Rani Jaiswal on 3/13/18.
//  Copyright © 2018 Rani Jaiswal. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController {

    @IBOutlet var photoButton: NSButtonCell!
    @IBOutlet var imageDisplay: NSImageCell!
    @IBOutlet var timerSecPicker: NSPopUpButton!
    var timerDict = [String:Double]()
    var currentTimer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        //updatePhoto()
        timerSecPicker.removeAllItems()
        timerSecPicker.addItem(withTitle: "1 sec")
        timerSecPicker.addItem(withTitle: "10 sec")
        timerSecPicker.addItem(withTitle: "30 sec")
        timerSecPicker.addItem(withTitle: "60 sec")
        timerSecPicker.addItem(withTitle: "Never")
        timerSecPicker.selectItem(withTitle: "10 sec")
        timerDict["1 sec"] = 1.0
        timerDict["10 sec"] = 10.0
        timerDict["30 sec"] = 30.0
        timerDict["60 sec"] = 60.0
        timerDict["Never"] = Double.infinity
        scheduledTimerWithTimeInterval(timeInSeconds: (timerSecPicker.selectedItem?.title)!)
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func timerSecChanged(sender: AnyObject) {
        let selection = sender as! NSPopUpButton
        let time = (selection.selectedItem?.title)!
        currentTimer.invalidate()
        scheduledTimerWithTimeInterval(timeInSeconds: time)
    }
    
    // Scheduling timer to call the function "updatePhoto()" with the given interval
    func scheduledTimerWithTimeInterval(timeInSeconds: String){
        let time = timerDict[timeInSeconds]
        currentTimer = Timer.scheduledTimer(timeInterval: time!, target: self, selector: #selector(ViewController.updatePhoto), userInfo: nil, repeats: true)
    }
    
    // calls updatePhoto() when 'take photo' button is pressed
    @IBAction func photoButtonPressed(sender: AnyObject) {
        updatePhoto()
        
    }

    // updates the photo displayed
    // TODO: figure out how to get windows above too
    func updatePhoto() {
        /*let windowsArray = CGWindowListCopyWindowInfo(CGWindowListOption.optionOnScreenOnly, kCGNullWindowID) as! [CFDictionary];
        var arrayForCGImage: [CGWindowID] = []
        let windowID = CGWindowID((self.view.window?.windowNumber)!)
        for windowDict in windowsArray {
            if let dict = windowDict as? [String: AnyObject] {
                if (dict["kCGWindowNumber"] as! UInt32 != windowID) {
                    arrayForCGImage.append(dict["kCGWindowNumber"] as! UInt32)
                }
            }
        }
        let array = arrayForCGImage as CFArray
        let cgimg = CGImage(windowListFromArrayScreenBounds: CGRect.infinite, windowArray: array, imageOption: CGWindowImageOption.nominalResolution)!
        let imageOnScreen = CIImage(cgImage: cgimg)*/

        let options =  CGWindowListOption(arrayLiteral: CGWindowListOption.optionOnScreenBelowWindow)
        let imageOnScreen = CIImage(cgImage: CGWindowListCreateImage(CGRect.infinite, options, CGWindowID((self.view.window?.windowNumber)!), CGWindowImageOption.nominalResolution)!)
        let lastCubeFilterData = UserDefaults.standard.data(forKey: "lastCubeFilter")
        let lastCubeFilter = NSKeyedUnarchiver.unarchiveObject(with: lastCubeFilterData!) as? CIFilter
        lastCubeFilter?.setValue(imageOnScreen, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        let filteredImage = lastCubeFilter?.outputImage!
        let finalImage = context.createCGImage(filteredImage!, from: (filteredImage?.extent)!)
        imageDisplay.image = NSImage.init(cgImage: finalImage!, size: NSZeroSize)
    }
}

