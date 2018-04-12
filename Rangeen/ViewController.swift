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
        configureTimer()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func configureTimer() {
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

    // take screenshot of all windows except Rangeen application
    func getScreenshot() -> CIImage {
        let windowsArray = CGWindowListCopyWindowInfo(CGWindowListOption.optionOnScreenOnly, kCGNullWindowID) as! [CFDictionary];
        var arrayForCGImage: [CGWindowID] = []
        let windowID = CGWindowID((self.view.window?.windowNumber)!)
        for windowDict in windowsArray {
            if let dict = windowDict as? [String: AnyObject] {
                if (dict["kCGWindowNumber"] as! UInt32 != windowID) {
                    arrayForCGImage.append(dict["kCGWindowNumber"] as! UInt32)
                }
            }
        }
        let pointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: arrayForCGImage.count)
        for (index, window) in arrayForCGImage.enumerated() {
            pointer[index] = UnsafeRawPointer(bitPattern: UInt(window))
        }
        let array: CFArray = CFArrayCreate(kCFAllocatorDefault, pointer, arrayForCGImage.count, nil)
        let cgimg = CGImage(windowListFromArrayScreenBounds: CGRect.infinite, windowArray: array, imageOption: [])!
        return CIImage(cgImage: cgimg)
    }
    
    // updates the photo displayed
    func updatePhoto() {
        var img: CIImage = getScreenshot()
        
        let fromDictData = UserDefaults.standard.data(forKey: "fromWellsArray")
        let fromDict = NSKeyedUnarchiver.unarchiveObject(with: fromDictData!) as? [String:NSColorWell]
        let toDictData = UserDefaults.standard.data(forKey: "toWellsArray")
        let toDict = NSKeyedUnarchiver.unarchiveObject(with: toDictData!) as? [String:NSColorWell]

        if fromDict!.count > 0 {
            for index in 0...(fromDict!.count - 1) {
                let colorFrom = fromDict?[String(index)]?.color
                let colorTo = toDict?[String(index)]?.color
                let filter = updateColorCube(colorFrom: colorFrom!, colorTo: colorTo!)
                filter.setValue(img, forKey: kCIInputImageKey)
                let filteredImage = filter.outputImage!
                img = filteredImage
            }
        }
        let context = CIContext(options: nil)
        let finalImage = context.createCGImage(img, from: (img.extent))
        imageDisplay.image = NSImage.init(cgImage: finalImage!, size: NSZeroSize)
    }
    
    // if color preferences have changed, updates colorCubeFilter
    func updateColorCube(colorFrom: NSColor, colorTo: NSColor) -> CIFilter {
        
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
        return colorCube
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

