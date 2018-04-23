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
    var setColorsText = "By clicking Set Colors, you can specify which colors on your screen you want to appear differently in the screenshot. For example, if you select a Red in the From column and a Blue in the To column, every red on your screen will be shown as a blue in the screenshot.\n\nThe application will adjust any color within 30 degrees in both directions of your selection on the color wheel to include the shades of your selected color. Once you apply your desired colors, the screenshots will update accordingly."
    var closingText = "Thank you for using Rangeen!"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setText(textToSet: welcomeText)
        setButtons(1)
        progress?.doubleValue = 25
    }
    
    @IBAction func continuePressed(sender: NSButton) {
        
        if let value = progress?.doubleValue {
            if value == 100.0 {
                self.dismiss(self)
            }
            if value < 100.0 {
                progress?.doubleValue += 25
            }
        }
        if (progress?.doubleValue == 50) {
            setText(textToSet: timerText)
            setButtons(2)
        }
        
        else if (progress?.doubleValue == 75) {
            setText(textToSet: setColorsText)
            setButtons(3)
        }
        
        else if (progress?.doubleValue == 100) {
            setText(textToSet: closingText)
            setButtons(4)
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
            setButtons(3)
        }
        else if (progress?.doubleValue == 50) {
            setText(textToSet: timerText)
            setButtons(2)
        }
        else if (progress?.doubleValue == 25) {
            setText(textToSet: welcomeText)
            setButtons(1)
        }
    }
    func setText(textToSet: String) {
        let attributedString = NSAttributedString(string: textToSet, attributes: ["Color": NSColor.black])
        text?.placeholderAttributedString = attributedString
    }
    func setButtons(_ page: Int) {
        if page == 1 {
            cont?.isHidden = false
            cont?.title = "Continue"
            back?.isHidden = true
        }
        else if page == 2 {
            cont?.isHidden = false
            cont?.title = "Continue"
            back?.isHidden = false
        }
        else if page == 3 {
            cont?.isHidden = false
            cont?.title = "Continue"
            back?.isHidden = false
        }
        else if page == 4 {
            cont?.isHidden = false
            cont?.title = "Done"
            back?.isHidden = false
        }
    }
}
