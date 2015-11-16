//
//  GameModel.swift
//  2048firtest
//
//  Created by RenPeng on 15/10/9.
//  Copyright © 2015年 RenPeng. All rights reserved.
//

import UIKit
protocol GameModelProtocol : class{
    func scoreChange(score : Int)
    func moveOneTile(from : (Int,Int) , to : (Int,Int) , value : Int)
    func moveTwoTiles(from : ((Int,Int),(Int,Int)) , to : (Int,Int) , value : Int)
    func insertTile(location : (Int,Int) , value : Int)
}
class GameModel : NSObject {
    unowned let delegate : GameModelProtocol
    var score :Int = 0{
        didSet{
            delegate.scoreChange(score)
        }
    }
    let dimension : Int
    let threshold : Int
    var gameboard : SquareGameBoard<TileObject>
    var queue:[MoveCommand]
    var timer: NSTimer
    var queueDelay = 0.3
    var MaxCommands = 100
    init(dimension : Int , threshold : Int , delegate : GameModelProtocol){
        self.delegate = delegate
        self.dimension = dimension
        self.threshold = threshold
        gameboard = SquareGameBoard(dimension: self.dimension, initValue: .Empty)
        queue = [MoveCommand]()
        timer = NSTimer()
        super.init()
    }
    func queueMove(direction : MoveDirection, completion : (Bool)->()){
        if (queue.count==MaxCommands){
            NSLog("too many commands")
            return
        }
        queue.append(MoveCommand(direction : direction , completion : completion))
        if (!timer.valid){
            fireTimer(timer)
        }
    }
    func fireTimer(_:NSTimer){
        if queue.count==0{
            return
        }
        var changed = false
        while queue.count > 0{
            let command = queue[0]
            queue.removeAtIndex(0)
            changed = performMove(command.direction)
            command.completion(changed)
            if changed{
                break
            }
            if changed{
                timer = NSTimer.scheduledTimerWithTimeInterval(queueDelay, target : self,
                    selector:
                    Selector("fireTimer"),
                    userInfo: nil ,
                    repeats: false)
            }
        }
    }
    func insertTile(position: (Int,Int),value : Int){
        let(x,y) = position
        if case .Empty = gameboard[x,y]{
            gameboard[x,y] = TileObject.Tile(value)
            delegate.insertTile(position, value: value)
        }
    }
    func insertTileAtRandomLocation(value : Int){
        let emptySpots = gameBoardEmptySpots()
        if emptySpots.isEmpty{
            return
        }
        let idx = Int(arc4random_uniform(UInt32(emptySpots.count-1)))
        let(x,y) = emptySpots[idx]
        insertTile((x,y), value: value)
    }
    func gameBoardEmptySpots() -> [(Int,Int)]{
        var buffer :[(Int,Int)] = []
        for i in 0..<dimension{
            for j in 0..<dimension{
                if case .Empty = gameboard[i,j]{
                    buffer += [(i,j)]
                }
            }
        }
        return buffer
    }
    func performMove(direction : MoveDirection)-> Bool{
        let coordinnateGenerator : (Int)-> [(Int,Int)] = { (iteration : Int) ->[(Int,Int)] in
            var buffer = Array<(Int,Int)>(count: self.dimension, repeatedValue: (0,0))
            for i in 0..<self.dimension {
                switch direction{
                case .Up : buffer[i] = (i,iteration)
                case .Down : buffer[i] = (self.dimension-1-i, iteration)
                case .Left : buffer[i] = (iteration,i)
                case .Right : buffer[i] = (iteration,self.dimension-1-i)
                }
            }
            return buffer
        }
        var atLastOneMove = false
        for i in 0..<self.dimension{
            let coors = coordinnateGenerator(i)
            let tiles = coors.map() {
                (c:(Int,Int)) -> TileObject in
                let (x,y)=c
                return self.gameboard[x,y]
            }
            let orders = merge(tiles)
            
            atLastOneMove = orders.count > 0 ? true : atLastOneMove
            for order in orders{
                switch order{
                case let .SingleMoveOrder(source: s, destination: d, value: v, wasMerge: merge):
                        if merge{
                            score += v
                    }
                        let (sx,sy) = coors[s]
                        let (dx,dy) = coors[d]
                        gameboard[sx,sy] = TileObject.Empty
                        gameboard[dx,dy] = TileObject.Tile(v)
                        delegate.moveOneTile((sx,sy), to: (dx,dy), value: v)
                case let .DoubleMoveOrder(firstSource: s1, secondSource: s2, destination: d, value: v):
                    let (s1x,s1y) = coors[s1]
                    let (s2x,s2y) = coors[s2]
                    let (dx,dy) = coors[d]
                    score += v
                    gameboard[s1x,s1y] = TileObject.Empty
                    gameboard[s2x,s2y] = TileObject.Empty
                    gameboard[dx,dy] = TileObject.Tile(v)
                    delegate.moveTwoTiles((coors[s1],coors[s2]), to: (dx,dy), value: v)
                }
            }
        }
        return atLastOneMove
    }
    func merge(group : [TileObject])->[MoveOrder]{
        return convert(collapse(condense(group)))
    }
    func condense(group : [TileObject]) ->[ActionToken]{
        var buffer = [ActionToken]()
        for (idx,tile) in group.enumerate(){
            switch tile{
            case let .Tile(v) where buffer.count == idx:
                buffer.append(ActionToken.NoAction(source: idx, value: v))
            case let .Tile(v):
                buffer.append(ActionToken.Move(source: idx, value: v))
            default:
                break
            }
        }
        return buffer
    }
    class func quiescentTileStillQuiescent(inputPosion: Int , outputLenth : Int,
        originalPosion: Int)->Bool{
            return (inputPosion == outputLenth) &&
            (outputLenth == originalPosion)
    }
    func collapse(group : [ActionToken]) ->[ActionToken]{
        var buffer = [ActionToken]()
        var skipNext = false
        for (idx,actionToken) in group.enumerate(){
            if skipNext{
                skipNext = false
                continue
            }
            switch actionToken{
            case let .NoAction(s,v) where (idx < group.count-1
                && v == group[idx+1].getValue()
                && GameModel.quiescentTileStillQuiescent(idx, outputLenth: buffer.count, originalPosion: s) ):
                let next = group[idx+1]
                let nv = v+next.getValue()
                skipNext = true
                buffer.append(ActionToken.SingleCombine(source : next.getSource(), value: nv))
            case let .NoAction(s,v) where (idx < group.count-1
                && v == group[idx+1].getValue()
                ):
                let next = group[idx+1]
                let nv = v + next.getValue()
                skipNext = true
                buffer.append(ActionToken.DoubleCombine(source: s, source: next.getSource(), value: nv))
            case let .NoAction(s,v) where !GameModel.quiescentTileStillQuiescent(idx, outputLenth: buffer.count, originalPosion: s):
                buffer.append(ActionToken.Move(source: s, value: v))
            case let .NoAction(s,v):
                buffer.append(ActionToken.NoAction(source: s, value: v))
            case let .Move(s,v):
                buffer.append(ActionToken.Move(source: s, value: v))
            default:
                continue
            }
        }
        return buffer
    }
    func convert(group : [ActionToken])->[MoveOrder]{
        var buffer : [MoveOrder] = []
        for (idx,token) in group.enumerate(){
            switch token{
            case let .Move(source: s, value: v):
                buffer.append(MoveOrder.SingleMoveOrder(source: s, destination: idx, value: v, wasMerge: false))
            case let .SingleCombine(source : s, value : v):
                buffer.append(MoveOrder.SingleMoveOrder(source: s, destination: idx, value: v, wasMerge: true))
            case let .DoubleCombine(source: s1, source: s2, value: v):
                buffer.append(MoveOrder.DoubleMoveOrder(firstSource: s1, secondSource: s2, destination: idx, value: v))
            default:
                break
            }
        }
        return buffer
    }
    func userHasWon() -> (Bool, (Int,Int)?){
        for i in 0..<dimension{
            for j in 0..<dimension{
                if case let .Tile(v) = gameboard[i,j] where v>=threshold{
                    return (true,(i,j))
                }
            }
        }
        return (false,nil)
    }
    func userHasLost() -> Bool{
        guard gameBoardEmptySpots().isEmpty else{
            return false
        }
        for i in 0..<dimension{
            for j in 0..<dimension{
                switch gameboard[i,j]{
                case .Empty:
                    NSLog("gameBoardEmptySpots error")
                case let .Tile(v):
                    if tileBelowHasSameValue((i,j), value: v) || tileLeftHasSameValue((i,j), value: v){
                        return false
                    }
                }
            }
        }
        return true
    }
    func tileBelowHasSameValue(location : (Int,Int), value : Int)->Bool{
        let (x,y) = location
        guard y != dimension-1 else{
            return false
        }
        if case let .Tile(v)=gameboard[x,y+1]{
            return v==value
        }
        return false
    }
    func tileLeftHasSameValue(location : (Int,Int) ,value : Int) ->Bool{
        let (x,y) = location
        guard x != dimension-1 else{
            return false
        }
        if case let .Tile(v) = gameboard[x+1,y]{
            return v == value
        }
        return false
    }
}

