//
//  ViewController.swift
//  Rangeen
//
//  Created by Rani Jaiswal on 3/13/18.
//  Copyright © 2018 Rani Jaiswal. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var photoButton: NSButtonCell!
    @IBOutlet var imageDisplay: NSImageCell!
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduledTimerWithTimeInterval()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to call the function "updatePhoto()" with the interval of 10 seconds
        _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(ViewController.updatePhoto), userInfo: nil, repeats: true)
        
    }

    func updatePhoto() {
        let options =  CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
        let imageCG = CGWindowListCreateImage(CGRect.infinite, options, kCGNullWindowID, CGWindowImageOption.nominalResolution)!
        imageDisplay.image = NSImage.init(cgImage: imageCG, size: NSZeroSize)
    }
    
    @IBAction func photoButtonPressed(sender: AnyObject) {
        updatePhoto()
    }

}

