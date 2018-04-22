//
//  Tutorial.swift
//  Rangeen
//
//  Created by Rani Jaiswal on 4/22/18.
//  Copyright © 2018 Rani Jaiswal. All rights reserved.
//

import Cocoa

class Tutorial: NSViewController {

    @IBOutlet var text: NSTextField?
    @IBOutlet var progress: NSProgressIndicator?
    @IBOutlet var cont: NSButton?
    @IBOutlet var back: NSButton?
    var welcomeText = "Welcome to Rangeen!\n\nThis application will take pictures of your screen and adjust the colors to your preferences."
    var timerText = "You can begin by specifying how often you'd like the screenshots taken through the dropdown at the top of the screen.\n\nFor example, you might want a picture taken every second as you're browsing an article, or you might a picture never to be taken unless you click Take Photo."
    var setColorsText = "By clicking Set Colors, you can specify which colors on your screen you want to appear differently in the screenshot.\n\nFor example, if you select a Red in the From column and a Blue in the To column, every red on your screen will be shown as a blue in the screenshot.\n\nThe application will adjust any color within 30 degrees in both directions of your selection on the color wheel to include the shades of your selected color. The application will adjust any color within 30 degrees in both directions of your selection on the color wheel to include the shades of your selected color."
    var closingText = "Thank you for using Rangeen!"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setText(textToSet: welcomeText)
        progress?.doubleValue = 25
        cont?.isHidden = false
        back?.isHidden = true
        text?.alignment = NSTextAlignment.center
    }
    
    @IBAction func continuePressed(sender: NSButton) {
        
        if let value = progress?.doubleValue {
            if value < 100.0 {
                progress?.doubleValue += 25
            }
        }
        if (progress?.doubleValue == 50) {
            setText(textToSet: timerText)
            back?.isHidden = false
        }
        
        else if (progress?.doubleValue == 75) {
            setText(textToSet: setColorsText)
        }
        
        else if (progress?.doubleValue == 100) {
            setText(textToSet: closingText)
            cont?.isHidden = true
        }
    }
    
    @IBAction func backPressed(sender: NSButton) {
        if let value = progress?.doubleValue {
            if value > 25.0 {
                progress?.doubleValue -= 25
            }
        }
        if (progress?.doubleValue == 75) {
            setText(textToSet: setColorsText)
            cont?.isHidden = false
        }
        else if (progress?.doubleValue == 50) {
            setText(textToSet: timerText)
        }
        else if (progress?.doubleValue == 25) {
            setText(textToSet: welcomeText)
            back?.isHidden = true
        }
    }
    func setText(textToSet: String) {
        let attributedString = NSAttributedString(string: textToSet, attributes: ["Color": NSColor.black])
        text?.placeholderAttributedString = attributedString

    }
    
}
