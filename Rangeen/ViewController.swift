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

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func photoButtonPressed(sender: AnyObject) {
        let options = CGWindowListOption.optionOnScreenOnly
        let imageCG = CGWindowListCreateImage(CGRect.infinite, options, kCGNullWindowID, CGWindowImageOption.nominalResolution)!
        imageDisplay.image = NSImage.init(cgImage: imageCG, size: NSZeroSize)
        
    }

}

