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
    var hueRange: Float = 60 //hue angle that we want to replace from TMReplaceColorHue
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
        // take screenshot DOESN'T WORK ABOVE WINDOWS :'(
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
        
        // working screenshot for windows below
        let options =  CGWindowListOption(arrayLiteral: CGWindowListOption.optionOnScreenBelowWindow)
        let imageOnScreen = CIImage(cgImage: CGWindowListCreateImage(CGRect.infinite, options, CGWindowID((self.view.window?.windowNumber)!), CGWindowImageOption.nominalResolution)!)

        var img: CIImage = imageOnScreen
        let fromDict = UserDefaults.standard.dictionary(forKey: "colorReplacementFrom")
        let toDict = UserDefaults.standard.dictionary(forKey: "colorReplacementTo")
        
        for index in 1...3 {
            let colorFrom = fromDict?[String(index)]
            let colorTo = toDict?[String(index)]
            
        }
        for _ in UserDefaults.standard.dictionaryRepresentation() {
            // build filter with new color combination
            // pass image through filter
            // update img
        }

        let lastCubeFilterData = UserDefaults.standard.data(forKey: "lastCubeFilter")
        let lastCubeFilter = NSKeyedUnarchiver.unarchiveObject(with: lastCubeFilterData!) as? CIFilter
        lastCubeFilter?.setValue(img, forKey: kCIInputImageKey)
        let filteredImage = lastCubeFilter?.outputImage!
        let context = CIContext(options: nil)
        let finalImage = context.createCGImage(filteredImage!, from: (filteredImage?.extent)!)
        imageDisplay.image = NSImage.init(cgImage: finalImage!, size: NSZeroSize)
    }
    
    // if color preferences have changed, updates colorCubeFilter
    func updateColorCube(colorFrom: NSColor, colorTo: NSColor) {
        
        var ptrFrom:CGFloat = 0.0
        colorFrom.getHue(&ptrFrom, saturation: nil, brightness: nil, alpha: nil)
        let defaultHue = Float(ptrFrom)*360.0
        let centerHueAngle: Float = Float(ptrFrom)
        
        var ptrTo:CGFloat = 0.0
        colorTo.getHue(&ptrTo, saturation: nil, brightness: nil, alpha: nil)
        let destCenterHueAngle: Float = Float(ptrTo)
        let minHueAngle: Float = (defaultHue - hueRange/2.0) / 360
        let maxHueAngle: Float = (defaultHue + hueRange/2.0) / 360
        let hueAdjustment = centerHueAngle - destCenterHueAngle
        let size = 64
        var cubeData = [Float](repeating: 0, count: size * size * size * 4)
        var rgb: [Float] = [0, 0, 0]
        var hsv: (h : Float, s : Float, v : Float)
        var newRGB: (r : Float, g : Float, b : Float)
        var offset = 0
        for z in 0 ..< size {
            rgb[2] = Float(z) / Float(size) // blue value
            for y in 0 ..< size {
                rgb[1] = Float(y) / Float(size) // green value
                for x in 0 ..< size {
                    rgb[0] = Float(x) / Float(size) // red value
                    hsv = RGBtoHSV(rgb[0], g: rgb[1], b: rgb[2])
                    if hsv.h < minHueAngle || hsv.h > maxHueAngle {
                        newRGB.r = rgb[0]
                        newRGB.g = rgb[1]
                        newRGB.b = rgb[2]
                    } else {
                        hsv.h = destCenterHueAngle == 1 ? 0 : hsv.h - hueAdjustment
                        newRGB = HSVtoRGB(hsv.h, s:hsv.s, v:hsv.v)
                    }
                    cubeData[offset] = newRGB.r
                    cubeData[offset+1] = newRGB.g
                    cubeData[offset+2] = newRGB.b
                    cubeData[offset+3] = 1.0
                    offset += 4
                }
            }
        }
        let b = cubeData.withUnsafeBufferPointer { Data(buffer: $0) }
        let data = b as NSData
        let colorCube = CIFilter(name: "CIColorCube")!
        colorCube.setValue(size, forKey: "inputCubeDimension")
        colorCube.setValue(data, forKey: "inputCubeData")
        
        let colorCubeData = NSKeyedArchiver.archivedData(withRootObject: colorCube) as NSData?
        UserDefaults.standard.set(colorCubeData, forKey: "lastCubeFilter")
        UserDefaults.standard.synchronize()
    }
    
    func HSVtoRGB(_ h : Float, s : Float, v : Float) -> (r : Float, g : Float, b : Float) {
        let col = NSColor(hue: CGFloat(h), saturation: CGFloat(s), brightness: CGFloat(v), alpha: 1.0)
        return (Float(col.redComponent), Float(col.greenComponent), Float(col.blueComponent))
    }
    
    func RGBtoHSV(_ r : Float, g : Float, b : Float) -> (h : Float, s : Float, v : Float) {
        let col = NSColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
        return (Float(col.hueComponent), Float(col.saturationComponent), Float(col.brightnessComponent))
    }

}

