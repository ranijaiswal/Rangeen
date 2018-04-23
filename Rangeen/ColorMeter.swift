//
//  ColorMeter.swift
//  Rangeen
//
//  Created by Rani Jaiswal on 4/23/18.
//  Copyright © 2018 Rani Jaiswal. All rights reserved.
//

import Cocoa

class ColorMeter: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // https://stackoverflow.com/questions/11746471/detect-color-under-mouse-mac?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa 
     //   autoreleasepool {
            // Grab the current mouse location.
            let mouseLoc: NSPoint = NSEvent.mouseLocation()
            // Grab the display for said mouse location.
            var count:UInt32 = 0
            var displayForPoint: CGDirectDisplayID = 0
            if CGGetDisplaysWithPoint(NSPointToCGPoint(mouseLoc), 1, &displayForPoint, &count) != .success {
                print("Oops.")
            }
            // Grab the color on said display at said mouse location.
            let image = CGDisplayCreateImage(displayForPoint, rect: CGRect(x: mouseLoc.x, y: mouseLoc.y, width: 1, height: 1))
            let bitmap = NSBitmapImageRep(cgImage: image!)
            let color: NSColor? = bitmap.colorAt(x: 0, y: 0)
            print("\(color ?? NSColor.clear)")

        //}
    }
    
}
