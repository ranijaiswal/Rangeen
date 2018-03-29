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
    @IBOutlet var colorPickerFrom: NSColorWell!
    @IBOutlet var colorPickerTo: NSColorWell!
    var lastColorFrom: NSColor!
    var lastColorTo: NSColor!
    var lastCubeFilter: CIFilter!
    var hueRange: Float = 60 //hue angle that we want to replace from TMReplaceColorHue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePhoto()
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
    
    // receive array of arrays of NSColors, of each group that looks the same
    /*func handleSimilarColors(groups: [[NSColor]]) {
        for colorGroup in groups {
            for color in colorGroup {
                
            }
        }
    }*/
    // updates the photo displayed
    // TODO: figure out what to do for "options"
    func updatePhoto() {
        updateColorCube()
        let options =  CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
        let imageOnScreen = CIImage(cgImage: CGWindowListCreateImage(CGRect.infinite, options, kCGNullWindowID, CGWindowImageOption.nominalResolution)!)
        lastCubeFilter.setValue(imageOnScreen, forKey: kCIInputImageKey)
        let context = CIContext(options: nil)
        let filteredImage = lastCubeFilter.outputImage!
        let finalImage = context.createCGImage(filteredImage, from: filteredImage.extent)
        imageDisplay.image = NSImage.init(cgImage: finalImage!, size: NSZeroSize)
    }
    
    // if color preferences have changed, updates colorCubeFilter
    func updateColorCube() {
        if (lastColorFrom != colorPickerFrom.color || lastColorTo != colorPickerTo.color) {
            print("HERE!")
            // get hue of colorPickerFrom
            var ptrFrom:CGFloat = 0.0
            colorPickerFrom.color.getHue(&ptrFrom, saturation: nil, brightness: nil, alpha: nil)
            let defaultHue = Float(ptrFrom)*360.0
            let centerHueAngle: Float = Float(ptrFrom)
            // get hue of colorPickerTo
            var ptrTo:CGFloat = 0.0
            colorPickerTo.color.getHue(&ptrTo, saturation: nil, brightness: nil, alpha: nil)
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
            
            // update lastColorFrom and To vars and current cube image
            lastColorFrom = colorPickerFrom.color
            lastColorTo = colorPickerTo.color
            lastCubeFilter = colorCube
        }
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

