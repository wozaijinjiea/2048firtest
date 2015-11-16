//
//  TileView.swift
//  2048firtest
//
//  Created by RenPeng on 15/10/9.
//  Copyright © 2015年 RenPeng. All rights reserved.
//

import Foundation
import UIKit

class TileView:UIView{
    var value:Int = 0{
        didSet{
            backgroundColor = delegate.tileColor(value)
            numberLabel.textColor = delegate.numberColor(value)
            numberLabel.text = "\(value)"
        }
    }
    unowned let delegate : AppearanceProviderProtocol
    let numberLabel : UILabel
    init(position: CGPoint, width: CGFloat, value: Int, radius: CGFloat, delegate d: AppearanceProviderProtocol){
        delegate=d
        numberLabel = UILabel(frame: CGRectMake(0, 0, width, width))
        numberLabel.font = delegate.fontForNumbers()
        numberLabel.textAlignment = NSTextAlignment.Center        
        super.init(frame : CGRectMake(position.x, position.y, width, width))
        addSubview(numberLabel)
        layer.cornerRadius = radius
        self.value = value
        backgroundColor = delegate.tileColor(value)
        numberLabel.textColor = delegate.numberColor(value)
        numberLabel.text = "\(value)"
    }
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
}
