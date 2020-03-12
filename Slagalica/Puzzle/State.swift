//
//  State.swift
//  Slagalica
//
//  Created by Ivan Almer on 12/08/2019.
//  Copyright © 2019 ialmer. All rights reserved.
//

import Foundation

class State: Hashable {
    let tiles: [[Tile]]
    let lastMove: ((Int, Int), Direction)?
    let previousState: State?
    let cost: Int
    
    init(tiles: [[Tile]], lastMove: ((Int, Int), Direction)?, previousState: State?, cost: Int) {
        self.tiles = tiles
        self.lastMove = lastMove
        self.previousState = previousState
        self.cost = cost
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tiles)
    }
    
    static func ==(lhs: State, rhs: State) -> Bool {
        for i in 0..<lhs.tiles.count {
            for j in 0..<rhs.tiles[0].count {
                if lhs.tiles[i][j] != rhs.tiles[i][j] { return false }
            }
        }
        return true
    }
}
