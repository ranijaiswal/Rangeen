//
//  CustomTableCellView.swift
//  Rangeen
//
//  Created by Rani Jaiswal on 4/8/18.
//  Copyright © 2018 Rani Jaiswal. All rights reserved.
//

import Cocoa

class CustomTableCellView: NSTableCellView {

    var well: NSColorWell = NSColorWell()
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

}
