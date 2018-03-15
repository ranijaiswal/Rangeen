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
    
    // from TMReplaceColorHue
    var defaultHue: Float = 205 // color of blue
    var hueRange: Float = 60 //hue angle that we want to replace
    
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
        _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.updatePhoto), userInfo: nil, repeats: true)
    }
    
    // calls updatePhoto() when 'take photo' button is pressed
    @IBAction func photoButtonPressed(sender: AnyObject) {
        updatePhoto()
    }
    
    // updates the photo displayed
    func updatePhoto() {
        let options =  CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
        let imageCG = CGWindowListCreateImage(CGRect.infinite, options, kCGNullWindowID, CGWindowImageOption.nominalResolution)!
        let finalImage = filterImage(imageCG: imageCG)
        imageDisplay.image = NSImage.init(cgImage: finalImage, size: NSZeroSize)
    }
  
    // adapted from TMReplaceColorHue
    func filterImage(imageCG: CGImage) -> CGImage {
        let ciImage = CIImage(cgImage: imageCG)
        let centerHueAngle: Float = defaultHue/360.0
        var ptr:CGFloat = 0.0
        colorPickerTo.color.getHue(&ptr, saturation: nil, brightness: nil, alpha: nil)
        let destCenterHueAngle: Float = Float(ptr)
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
        colorCube.setValue(ciImage, forKey: kCIInputImageKey)
        let outImage = colorCube.outputImage!
        let context = CIContext(options: nil)
        let outputImageRef = context.createCGImage(outImage, from: outImage.extent)
        return outputImageRef!
    }
    
    // from TMReplaceColorHue
    func HSVtoRGB(_ h : Float, s : Float, v : Float) -> (r : Float, g : Float, b : Float) {
        var r : Float = 0
        var g : Float = 0
        var b : Float = 0
        let C = s * v
        let HS = h * 6.0
        let X = C * (1.0 - fabsf(fmodf(HS, 2.0) - 1.0))
        if (HS >= 0 && HS < 1) {
            r = C
            g = X
            b = 0
        } else if (HS >= 1 && HS < 2) {
            r = X
            g = C
            b = 0
        } else if (HS >= 2 && HS < 3) {
            r = 0
            g = C
            b = X
        } else if (HS >= 3 && HS < 4) {
            r = 0
            g = X
            b = C
        } else if (HS >= 4 && HS < 5) {
            r = X
            g = 0
            b = C
        } else if (HS >= 5 && HS < 6) {
            r = C
            g = 0
            b = X
        }
        let m = v - C
        r += m
        g += m
        b += m
        return (r, g, b)
    }
    
    // from TMReplaceColorHue
    func RGBtoHSV(_ r : Float, g : Float, b : Float) -> (h : Float, s : Float, v : Float) {
        var h : CGFloat = 0
        var s : CGFloat = 0
        var v : CGFloat = 0
        let col = NSColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
        col.getHue(&h, saturation: &s, brightness: &v, alpha: nil)
        return (Float(h), Float(s), Float(v))
    }
}

