//
//  ScoreBoard.swift
//  2048firtest
//
//  Created by RenPeng on 15/10/9.
//  Copyright © 2015年 RenPeng. All rights reserved.
//

import UIKit
protocol ScoreViewProtocol {
    func scoreChanged(score : Int)
}
class ScoreView : UIView,ScoreViewProtocol{
    var score : Int = 0{
        didSet{
            label.text = "\(score)"
        }
    }
    var label : UILabel
    func scoreChanged(score: Int) {
        self.score = score
    }
    let defaultFrame = CGRectMake(0, 0, 140, 40)
    init (backgroundColor : UIColor, numberColor : UIColor, numberFont : UIFont,
        radius : CGFloat){
            
            label = UILabel(frame: defaultFrame)
            label.textColor = numberColor
            label.textAlignment = NSTextAlignment.Center
            super.init(frame : defaultFrame)
            self.backgroundColor = backgroundColor
            label.font = numberFont
            layer.cornerRadius = radius
            self.addSubview(label)
    }
    required init(coder aCoder : NSCoder){
        fatalError("NSCoding not supported")
    }
}