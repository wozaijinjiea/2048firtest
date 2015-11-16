//
//  GameBoard.swift
//  2048firtest
//
//  Created by RenPeng on 15/10/9.
//  Copyright © 2015年 RenPeng. All rights reserved.
//

import UIKit
class GameBoardView : UIView{
    var dimension : Int
    var tileWidth : CGFloat
    var tilePadding : CGFloat
    var radius : CGFloat
    var tiles : Dictionary<NSIndexPath , TileView>
    let provider = AppearanceProvider()
    let tilePopStartScale: CGFloat = 0.1
    let tilePopMaxScale: CGFloat = 1.1
    let tilePopDelay: NSTimeInterval = 0.05
    let tileExpandTime: NSTimeInterval = 0.18
    let tileContractTime: NSTimeInterval = 0.08
    
    let tileMergeStartScale: CGFloat = 0.5
    let tileMergeExpandTime: NSTimeInterval = 0.08
    let tileMergeContractTime: NSTimeInterval = 0.08
    
    let perSquareSlideDuration: NSTimeInterval = 0.08
    init(dimension d : Int, tileWidth width : CGFloat , tilePadding padding : CGFloat, radius r : CGFloat ,
        backgroundColor : UIColor , foregroundColor : UIColor){
            assert (d>0)
            dimension = d
            tileWidth = width
            tilePadding = padding
            radius = r
            tiles = Dictionary()
            let sideLength = tilePadding + CGFloat(dimension)*(tilePadding + tileWidth)
            super.init(frame: CGRectMake(0, 0, sideLength, sideLength))
            layer.cornerRadius = radius
            setUpBackground(backgroundColor : backgroundColor , tileColor : foregroundColor)
    }
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    func setUpBackground(backgroundColor bgColor: UIColor, tileColor : UIColor){
        backgroundColor = bgColor
        var xCursor = tilePadding
        var yCursor : CGFloat
        let bgRadius = radius > 2 ? radius - 2 : 0
        for _ in 0..<dimension{
            yCursor = tilePadding
            for _ in 0..<dimension{
                let background = UIView(frame: CGRectMake(xCursor, yCursor, tileWidth, tileWidth))
                background.layer.cornerRadius = bgRadius
                background.backgroundColor = tileColor
                addSubview(background)
                yCursor += tilePadding + tileWidth
            }
            xCursor += tilePadding + tileWidth
        }
    }
    func positionIsValid(position : (Int,Int))->Bool{
        let (x,y) = position
        return x >= 0 && x < dimension
        && y >= 0 && y < dimension
    }
    func insertTile(position :(Int,Int), value : Int){
        assert(positionIsValid(position))
        let (row , col) = position
        let x = tilePadding + CGFloat(col) * (tileWidth + tilePadding)
        let y = tilePadding + CGFloat(row) * (tileWidth + tilePadding)
        let r = radius > 2 ? radius - 2 : 0
        let tile = TileView(position: CGPointMake(x, y), width: tileWidth, value: value, radius: r, delegate: provider)
        tile.layer.setAffineTransform(CGAffineTransformMakeScale(tilePopStartScale, tilePopStartScale))
        addSubview(tile)
        bringSubviewToFront(tile)
        tiles[NSIndexPath(forRow: row, inSection: col)] = tile
        UIView.animateWithDuration(tileExpandTime, animations: {
                tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
            }, completion: {finished in
                UIView.animateWithDuration(self.tileContractTime, animations: {
                        ()-> Void in
                    tile.layer.setAffineTransform(CGAffineTransformIdentity)
                    })
        })
    }
    func MoveOneTile(from : (Int,Int) , to : (Int,Int) ,value : Int){
        assert(positionIsValid(from) && positionIsValid( to))
        let (frow,fcol) = from
        let (trow,tcol) = to
        let fromKey = NSIndexPath(forRow: frow, inSection: fcol)
        let toKey = NSIndexPath(forRow: trow, inSection: tcol)
        guard let tile = tiles[fromKey]else{
            assert(false,"placeholder is error")
        }
        let tx = tilePadding + CGFloat(tcol) * (tilePadding + tileWidth)
        let ty = tilePadding + CGFloat(trow) * (tilePadding + tileWidth)
        let endTile = tiles[toKey]
        var finalFrame = tile.frame
        finalFrame.origin.x = tx
        finalFrame.origin.y = ty
        tiles.removeValueForKey(fromKey)
        tiles[toKey] = tile
        let shouldPop = (endTile != nil)
        UIView.animateWithDuration(perSquareSlideDuration, animations: {
                tile.frame = finalFrame
            }, completion:{(finished : Bool) -> Void in
                tile.value = value
                endTile?.removeFromSuperview()
                if !shouldPop || !finished{
                    return
                }
                tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
                UIView.animateWithDuration(self.tileMergeExpandTime , animations: {
                    tile.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
                    }, completion: {(finished : Bool )->Void in
                        UIView.animateWithDuration(self.tileContractTime){
                            tile.layer.setAffineTransform(CGAffineTransformIdentity)
                        }
        })
    })
    }
    func MoveTwoTiles(from : ((Int,Int),(Int,Int)), to : (Int,Int) , value : Int){
//        assert(positionIsValid(from.0) && positionIsValid(from.1) &&
//        positionIsValid(to))
//        let (fromRowA,fromColA) = from.0
//        let (fromRowB,fromColB) = from.1
//        let (toRow,toCol) = to
//        let fromKeyA = NSIndexPath(forRow: fromRowA, inSection: fromColA)
//        let fromKeyB = NSIndexPath(forRow: fromRowB, inSection: fromColB)
//        let toKey = NSIndexPath(forRow: toRow, inSection: toCol)
//        guard let fTileA = tiles[fromKeyA] else{
//            assert(false,"placeholder is error")
//        }
//        guard let fTileB = tiles[fromKeyB] else{
//            assert(false,"placeholder is error")
//        }
//        let oldTile = tiles[toKey]
//        let x = tilePadding + CGFloat(toCol) * (tilePadding + tileWidth)
//        let y = tilePadding + CGFloat(toRow) * (tilePadding + tileWidth)
//        var finalFrame = fTileA.frame
//        finalFrame.origin.x = x
//        finalFrame.origin.y = y
//        oldTile?.removeFromSuperview()
//        tiles.removeValueForKey(fromKeyA)
//        tiles.removeValueForKey(fromKeyB)
//        tiles[toKey] = fTileA
//        UIView.animateWithDuration(perSquareSlideDuration,
//            delay : 0.0,
//            options : UIViewAnimationOptions.BeginFromCurrentState,
//            animations: {
//                fTileA.frame = finalFrame
//                fTileB.frame = finalFrame
//            }, completion:{(finished :Bool) -> Void in
//            fTileB.removeFromSuperview()
//                fTileA.value = value
//                if !finished{
//                return
//                }
//                fTileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
//                UIView.animateWithDuration(self.tileMergeExpandTime,
//                    animations: {
//                        fTileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
//                    }, completion: { finished in
//                        UIView.animateWithDuration(self.tileMergeContractTime) {
//                            fTileA.layer.setAffineTransform(CGAffineTransformIdentity)
//                        }
//                })
//        })
        assert(positionIsValid(from.0) && positionIsValid(from.1) && positionIsValid(to))
        let (fromRowA, fromColA) = from.0
        let (fromRowB, fromColB) = from.1
        let (toRow, toCol) = to
        let fromKeyA = NSIndexPath(forRow: fromRowA, inSection: fromColA)
        let fromKeyB = NSIndexPath(forRow: fromRowB, inSection: fromColB)
        let toKey = NSIndexPath(forRow: toRow, inSection: toCol)
        
        guard let tileA = tiles[fromKeyA] else {
            assert(false, "placeholder error")
        }
        guard let tileB = tiles[fromKeyB] else {
            assert(false, "placeholder error")
        }
        
        // Make the frame
        var finalFrame = tileA.frame
        finalFrame.origin.x = tilePadding + CGFloat(toCol)*(tileWidth + tilePadding)
        finalFrame.origin.y = tilePadding + CGFloat(toRow)*(tileWidth + tilePadding)
        
        // Update the state
        let oldTile = tiles[toKey]  // TODO: make sure this doesn't cause issues
        oldTile?.removeFromSuperview()
        tiles.removeValueForKey(fromKeyA)
        tiles.removeValueForKey(fromKeyB)
        tiles[toKey] = tileA
        
        UIView.animateWithDuration(perSquareSlideDuration,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                // Slide tiles
                tileA.frame = finalFrame
                tileB.frame = finalFrame
            },
            completion: { finished in
                tileA.value = value
                tileB.removeFromSuperview()
                if !finished {
                    return
                }
                tileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tileMergeStartScale, self.tileMergeStartScale))
                UIView.animateWithDuration(self.tileMergeExpandTime,
                    animations: {
                        tileA.layer.setAffineTransform(CGAffineTransformMakeScale(self.tilePopMaxScale, self.tilePopMaxScale))
                    },
                    completion: { finished in
                        // Contract tile to original size
                        UIView.animateWithDuration(self.tileMergeContractTime) {
                            tileA.layer.setAffineTransform(CGAffineTransformIdentity)
                        }
                })
        })
}
    func reset(){
        for (_,object) in tiles{
            object.removeFromSuperview()
        }
        tiles.removeAll(keepCapacity: true)
    }
}
