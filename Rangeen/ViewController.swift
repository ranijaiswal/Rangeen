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
    override func viewDidLoad() {
        super.viewDidLoad()
        //updatePhoto()
        scheduledTimerWithTimeInterval()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // Scheduling timer to call the function "updatePhoto()" with the interval of 10 seconds
    func scheduledTimerWithTimeInterval(){
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.updatePhoto), userInfo: nil, repeats: true)
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

