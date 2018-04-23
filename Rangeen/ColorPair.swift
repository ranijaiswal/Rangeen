//
//  ColorPair.swift
//  Rangeen
//
//  Created by Rani Jaiswal on 4/22/18.
//  Copyright © 2018 Rani Jaiswal. All rights reserved.
//

import Foundation
import AppKit

class ColorPair : NSObject, NSCoding {
    var from: NSColor
    var to: NSColor
    
    init(from: NSColor, to: NSColor) {
        self.from = from
        self.to = to
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let red = aDecoder.decodeObject(forKey: "toRed") as? CGFloat,
            let green = aDecoder.decodeObject(forKey: "toGreen") as? CGFloat,
            let blue = aDecoder.decodeObject(forKey: "toBlue") as? CGFloat,
            let alpha = aDecoder.decodeObject(forKey: "toAlpha") as? CGFloat {
            to = NSColor(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return nil
        }
        if let red = aDecoder.decodeObject(forKey: "fromRed") as? CGFloat,
            let green = aDecoder.decodeObject(forKey: "fromGreen") as? CGFloat,
            let blue = aDecoder.decodeObject(forKey: "fromBlue") as? CGFloat,
            let alpha = aDecoder.decodeObject(forKey: "fromAlpha") as? CGFloat {
            from = NSColor(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(to.redComponent, forKey: "toRed")
        aCoder.encode(to.blueComponent, forKey: "toBlue")
        aCoder.encode(to.greenComponent, forKey: "toGreen")
        aCoder.encode(to.alphaComponent, forKey: "toAlpha")
        aCoder.encode(from.redComponent, forKey: "fromRed")
        aCoder.encode(from.blueComponent, forKey: "fromBlue")
        aCoder.encode(from.greenComponent, forKey: "fromGreen")
        aCoder.encode(from.alphaComponent, forKey: "fromAlpha")
    }
}
