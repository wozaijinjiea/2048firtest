//
//  2048Game.swift
//  2048firtest
//
//  Created by RenPeng on 15/10/10.
//  Copyright © 2015年 RenPeng. All rights reserved.
//

import Foundation
import UIKit
class GameController :  UIViewController,GameModelProtocol{
    var gameModel : GameModel?
    var gameboardView : GameBoardView?
    var scoreView : ScoreViewProtocol?
    var dimension : Int
    var threshold : Int
    let boardWidth : CGFloat = 230.0
    let thinPadding : CGFloat = 3.0
    let thickPadding : CGFloat = 6.0
    let viewPadding : CGFloat = 10.0
    let verticalViewPadding : CGFloat = 0.0
    init(dimension d : Int, threshold t: Int){
        self.dimension = d > 2 ? d : 2
        self.threshold = t > 8 ? t : 8
        super.init(nibName : nil, bundle : nil)
        gameModel = GameModel(dimension: dimension, threshold: threshold, delegate: self)
        view.backgroundColor = UIColor.whiteColor()
        setupSwipeControls()
    }
    required init (coder aDoder : NSCoder){
        fatalError("nscoding not support")
    }
    func setupSwipeControls(){
        let upSwipe = UISwipeGestureRecognizer(target: self, action: Selector("up:"))
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = UISwipeGestureRecognizerDirection.Up
        view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self, action: Selector("down:"))
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(downSwipe)

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("left:"))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.Left
        view.addGestureRecognizer(leftSwipe)

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("right:"))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        view.addGestureRecognizer(rightSwipe)

    }
    override func viewDidLoad(){
        super.viewDidLoad()
        startGame()
    }
    func startGame(){
        let viewWidth = view.bounds.size.width
        let viewHight = view.bounds.size.height
        func xPostionToCenter(v : UIView)->CGFloat{
            let leftPadding = 0.5 * (viewWidth - v.bounds.size.width)
            return CGFloat(leftPadding > 0 ? Int(leftPadding) : 0)
        }
        func yPostionToCenter(vs : [UIView] , order : Int)-> CGFloat{
            assert(vs.count > 0)
            assert(order >= 0 && order < vs.count)
            let totalHight = viewPadding * CGFloat(vs.count-1) + vs.map({$0.bounds.size.height}).reduce(verticalViewPadding, combine: {$0 + $1})
            var upPadding = 0.5 * (viewHight - totalHight)
            upPadding = upPadding > 0 ? upPadding : 0
            var acc :CGFloat = 0
            for i in 0..<order{
                acc += vs[i].bounds.size.height + viewPadding
            }
            return upPadding + acc
        }
            let scoreView = ScoreView(backgroundColor: UIColor.brownColor(),
            numberColor: UIColor.whiteColor(),
            numberFont : UIFont(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFontOfSize(16.0),
            radius: 6)
            scoreView.score = 0
        let tilePadding = dimension > 4 ? thickPadding : thinPadding
            let w : CGFloat = viewWidth - CGFloat(dimension + 1) * tilePadding
            let tileWidth : CGFloat = CGFloat(floorf(CFloat(w)))/CGFloat(dimension)
            let gameboardView = GameBoardView(dimension: dimension, tileWidth: tileWidth, tilePadding: tilePadding, radius: 10, backgroundColor: UIColor.blackColor(), foregroundColor: UIColor.brownColor())
            let views = [scoreView, gameboardView]
            scoreView.frame.origin.x = xPostionToCenter(scoreView)
            scoreView.frame.origin.y = yPostionToCenter(views, order: 0)
            view.addSubview(scoreView)
            self.scoreView = scoreView
            gameboardView.frame.origin.x = xPostionToCenter(gameboardView)
            gameboardView.frame.origin.y = yPostionToCenter(views, order: 1)
            view.addSubview(gameboardView)
            self.gameboardView = gameboardView
            assert(self.gameModel != nil)
            let g = self.gameModel!
            g.insertTileAtRandomLocation(2)
            g.insertTileAtRandomLocation(2)
    }
    func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
        assert(self.gameboardView != nil)
        let b = gameboardView
        b!.MoveOneTile(from, to: to, value: value)
    }
    func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        assert(gameboardView != nil)
        let b = gameboardView
        b!.MoveTwoTiles(from, to: to, value: value)
    }
    func insertTile(location: (Int, Int), value: Int) {
        assert(gameboardView != nil)
        let b = gameboardView
        b!.insertTile(location, value: value)
    }
    func scoreChange(score: Int) {
        if scoreView == nil{
            return
        }
        let s = scoreView!
        s.scoreChanged(score)
    }
    func followUp(){
        assert(gameModel != nil)
        let  g = gameModel!
        let (userWon,_) = g.userHasWon()
        if userWon{
            let viewalert = UIAlertView()
            viewalert.title = "YouWin"
            viewalert.addButtonWithTitle("cancel")
            viewalert.show()
            return
        }
        let random = Int(arc4random_uniform(10))
        g.insertTileAtRandomLocation(1 > random ? 4 : 2)
        if g.userHasLost(){
            let viewalert = UIAlertView()
            viewalert.title = "Lose"
            viewalert.addButtonWithTitle("cancel")
            viewalert.show()
        }
    }
    @objc(up:)
    func upCommand(r : UIGestureRecognizer){
        assert(gameModel != nil)
        let g = gameModel!
        g.queueMove(MoveDirection.Up, completion: {(changed : Bool) -> Void
            in
            if changed{
                self.followUp()
            }
        })
    }
    @objc(down:)
    func downCommand (r : UIGestureRecognizer){
        assert(gameModel != nil)
        let g = gameModel!
        g.queueMove(MoveDirection.Down, completion: {
            (changed : Bool) -> Void
            in
            if changed{
                self.followUp()
            }
        })
    }
    @objc(left:)
    func leftCommand (r : UIGestureRecognizer){
        assert(gameModel != nil)
        let g = gameModel!
        g.queueMove(MoveDirection.Left, completion: {
            (changed : Bool) -> Void
            in
            if changed{
                self.followUp()
            }
        })
    }
    @objc(right:)
    func rightCommand (r : UIGestureRecognizer){
        assert(gameModel != nil)
        let g = gameModel!
        g.queueMove(MoveDirection.Right, completion: {
            (changed : Bool) -> Void
            in
            if changed{
                self.followUp()
            }
        })
    }
}
