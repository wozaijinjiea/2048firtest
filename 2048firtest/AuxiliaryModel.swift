//
//  AuxiliaryModel.swift
//  2048firtest
//
//  Created by RenPeng on 15/10/9.
//  Copyright © 2015年 RenPeng. All rights reserved.
//

import Foundation
enum MoveDirection{
    case Up,Down,Left,Right
}
enum ActionToken{
    case NoAction(source: Int, value: Int)
    case Move(source: Int,value: Int)
    case SingleCombine(source: Int, value: Int)
    case DoubleCombine(source: Int, source: Int, value: Int)
    func getValue()->Int{
        switch(self){
            case let .NoAction(_,v): return v
            case let .Move(_,v): return v
            case let .SingleCombine(_,v): return v
            case let .DoubleCombine(_,_,v): return v
        }
    }
    func getSource()->Int{
        switch(self){
        case let .NoAction(s,_): return s
        case let .Move(s,_): return s
        case let .SingleCombine(s,_): return s
        case let .DoubleCombine(s,_,_): return s
        }
    }

}
enum TileObject{
    case Empty
    case Tile(Int)
}
struct MoveCommand{
    let direction: MoveDirection
    let completion: (Bool)->()
}
enum MoveOrder{
    case SingleMoveOrder(source: Int,destination: Int,value: Int,wasMerge: Bool)
    case DoubleMoveOrder(firstSource: Int,secondSource: Int,destination: Int,value: Int)
}
struct SquareGameBoard<T>{
    var boardArr: [T]
    let  dimension: Int
    init(dimension d: Int, initValue: T){
        dimension = d
        boardArr = [T](count: d*d, repeatedValue: initValue)
    }
    subscript(row: Int, col: Int)->T{
        get{
            assert(row>=0 && row<dimension)
            assert(col>=0 && row<dimension)
            return boardArr[row*dimension + col]
        }
        set{
            assert(row>=0 && row<dimension)
            assert(col>=0 && row<dimension)
            boardArr[row*dimension + col] = newValue
        }
    }
    mutating func setAll(item: T){
        for i in 0..<dimension{
            for j in 0..<dimension{
                self[i,j] = item
            }
        }
    }
    
}
