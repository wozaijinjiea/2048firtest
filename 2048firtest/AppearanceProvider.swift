//
//  AppearanceProvider.swift
//  2048firtest
//
//  Created by RenPeng on 15/10/9.
//  Copyright © 2015年 RenPeng. All rights reserved.
//

//import Foundation
//import UIKit
//protocol AppearanceProviderProtocol :class{
//    func tileColor(value : Int)-> UIColor
//    func numberColor(value : Int)-> UIColor
//    func fontForNumbers(value : Int)-> UIFont
//}
//class AppearanceProvider :AppearanceProviderProtocol {
//    func tileColor(value: Int) -> UIColor {
//        return UIColor(red: 1.0/255.0, green: 1.0/255.0, blue: 1.0/255.0, alpha: 1.0)
//    }
//    func numberColor(value: Int) -> UIColor {
//        return UIColor(red: 1.0/255.0, green: 1.0/255.0, blue: 1.0/255.0, alpha: 1.0)
//    }
//    func fontForNumbers(value: Int) -> UIFont {
//        if let font = UIFont(name: "HelveticaNeue-Bold", size: 20){
//            return font
//        }
//        return UIFont.systemFontOfSize(20)
//    }
//}
import UIKit

protocol AppearanceProviderProtocol: class {
    func tileColor(value: Int) -> UIColor
    func numberColor(value: Int) -> UIColor
    func fontForNumbers() -> UIFont
}

class AppearanceProvider: AppearanceProviderProtocol {
    
    // Provide a tile color for a given value
    func tileColor(value: Int) -> UIColor {
        switch value {
        case 2:
            return UIColor(red: 238.0/255.0, green: 228.0/255.0, blue: 218.0/255.0, alpha: 1.0)
        case 4:
            return UIColor(red: 237.0/255.0, green: 224.0/255.0, blue: 200.0/255.0, alpha: 1.0)
        case 8:
            return UIColor(red: 242.0/255.0, green: 177.0/255.0, blue: 121.0/255.0, alpha: 1.0)
        case 16:
            return UIColor(red: 245.0/255.0, green: 149.0/255.0, blue: 99.0/255.0, alpha: 1.0)
        case 32:
            return UIColor(red: 246.0/255.0, green: 124.0/255.0, blue: 95.0/255.0, alpha: 1.0)
        case 64:
            return UIColor(red: 246.0/255.0, green: 94.0/255.0, blue: 59.0/255.0, alpha: 1.0)
        case 128, 256, 512, 1024, 2048:
            return UIColor(red: 237.0/255.0, green: 207.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        default:
            return UIColor.whiteColor()
        }
    }
    
    // Provide a numeral color for a given value
    func numberColor(value: Int) -> UIColor {
        switch value {
        case 2, 4:
            return UIColor(red: 119.0/255.0, green: 110.0/255.0, blue: 101.0/255.0, alpha: 1.0)
        default:
            return UIColor.whiteColor()
        }
    }
    
    // Provide the font to be used on the number tiles
    func fontForNumbers() -> UIFont {
        if let font = UIFont(name: "HelveticaNeue-Bold", size: 20) {
            return font
        }
        return UIFont.systemFontOfSize(20)
    }
}