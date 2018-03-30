//
//  SetColors.swift
//  Rangeen
//
//  Created by Rani Jaiswal on 3/29/18.
//  Copyright © 2018 Rani Jaiswal. All rights reserved.
//

import Cocoa

class SetColors: NSViewController {

    @IBOutlet var colorPickerFrom: NSColorWell!
    @IBOutlet var colorPickerTo: NSColorWell!
    @IBOutlet var saveButton: NSButton!
    var lastColorFrom: NSColor!
    var lastColorTo: NSColor!
    var hueRange: Float = 60 //hue angle that we want to replace from TMReplaceColorHue

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        updateColorCube()
        dismissViewController(self)
    }
    // if color preferences have changed, updates colorCubeFilter
    func updateColorCube() {
        if (lastColorFrom != colorPickerFrom.color || lastColorTo != colorPickerTo.color) {
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
            let colorCubeData = NSKeyedArchiver.archivedData(withRootObject: colorCube) as NSData?
            UserDefaults.standard.set(colorCubeData, forKey: "lastCubeFilter")
            UserDefaults.standard.synchronize()
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
