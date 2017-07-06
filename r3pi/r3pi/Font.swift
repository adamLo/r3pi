//
//  Font.swift
//  r3pi
//
//  Created by Adam Lovastyik [Standard] on 06/07/2017.
//  Copyright © 2017 Adam Lovastyik. All rights reserved.
//

import Foundation
import UIKit

enum FontStyle: String {
    
    case regular    = ""
    case bold       = "-Bold"
    case light      = "-Light"
    case italic     = "-Italic"
    case medium     = "-Medium"
}

extension UIFont {
    
    // MARK: - Helpers
    
    class func defaultFont(style fontStyle:FontStyle, size: CGFloat) -> UIFont {
        
        let fontName = "HelveticaNeue" + fontStyle.rawValue
        
        var font  = UIFont(name: fontName, size: size)
        
        if font == nil {
            // Fall back to system font
            font = UIFont.systemFont(ofSize: size)
        }
        
        return font!
    }
    
    class func installedFonts() {
        
        for family in UIFont.familyNames {
            print("\(family)")
            let fam: String = family
            for name in UIFont.fontNames(forFamilyName: fam) {
                print("\t\(name)")
            }
        }
    }
}
