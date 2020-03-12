//
//  ViewController.swift
//  Slagalica
//
//  Created by Ivan Almer on 08/08/2019.
//  Copyright © 2019 ialmer. All rights reserved.
//

import UIKit

class PuzzleViewController: UIViewController {

    @IBOutlet weak var puzzleView: PuzzleView!
    @IBOutlet weak var solveButton: UIButton!
    
    private var firstLoad = true
    
    private var open: [State] = []
    private var closed = Set<State>()
    private var currentState: State?
    private var aStarComparator: (State, State) -> Bool = { s1, s2 in
        return (s1.cost + heuristic(state: s1)) < (s2.cost + heuristic(state: s2))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var searchViewController = SearchViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        puzzleView.delegate = self
        solveButton.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstLoad {
            puzzleView.shufflePuzzle(n: 20)
            firstLoad = false
        }
    }
    
    private func isGoalState(tiles: [[Tile]]) -> Bool {
        for i in 0..<3 {
            for j in 0..<3 {
                if i == 2, j == 2, tiles[i][j] == .empty { return true }
                if tiles[i][j] != .value(i * 3 + j + 1) { return false }
            }
        }
        return true
    }
    
    @IBAction func didTapSolveButton(_ sender: UIButton) {
        let queue = DispatchQueue(label: "Background")
        
        queue.async { [weak self] in
            self?.performSearch()
        }
        
        searchViewController.modalPresentationStyle = .overFullScreen
        searchViewController.modalTransitionStyle = .crossDissolve
        present(searchViewController, animated: true)
    }
    
    private func performSearch() {
        guard let s0 = currentState else { return }
        open.removeAll()
        closed.removeAll()
        
        open.append(s0)
        
        while !open.isEmpty {
            let node = open.removeFirst()
            if isGoalState(tiles: node.tiles) {
                let solution = reconstructPath(state: node)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.searchViewController.dismiss(animated: true) {
                        self.puzzleView.makeMoves(moves: solution)
                    }
                }
                return
            }
            closed.update(with: node)
            let children = expand(state: node)
            
            for child in children {
                if let index = open.firstIndex(of: child) {
                    if open[index].cost > child.cost {
                        open.remove(at: index)
                    } else if open[index].cost <= child.cost {
                        continue
                    }
                }
                if let index = closed.firstIndex(of: child) {
                    if closed[index].cost > child.cost {
                        closed.remove(at: index)
                    } else if closed[index].cost <= child.cost {
                        continue
                    }
                }
                open.append(child)
            }
            open.sort(by: aStarComparator)
            print(open.count)
        }
    }
    
    private static func heuristic(state: State) -> Int {
        var distance = 0
        for i in 0..<3 {
            for j in 0..<3 {
                if case .empty = state.tiles[i][j] { continue }
                let goal = goalPosition(of: state.tiles[i][j])
                distance += abs(i - goal.0) + abs(j - goal.1)
            }
        }
        return distance
    }
    
    private static func goalPosition(of tile: Tile) -> (Int, Int) {
        if case let .value(number) = tile {
            return ((number - 1) / 3, (number - 1) % 3)
        } else {
            return (2,2)
        }
    }
    
    private static func cost(state1: [[Tile]], state2: [[Tile]]) -> Int {
        // always the same cost
        return 1
    }
    
    private func printPuzzle(tiles: [[Tile]]) {
        for i in 0..<3 {
            var s = ""
            for j in 0..<3 {
                if case let .value(number) = tiles[i][j] {
                    s.append("\(number) ")
                } else if case .empty = tiles[i][j] {
                    s.append("  ")
                }
            }
            print(s)
        }
    }
    
    private func expand(state: State) -> [State] {
        guard let emptyPosition = position(of: .empty, tiles: state.tiles) else { return [] }
        let moves = allMoves(on: emptyPosition)
        
        let movableTiles = moves.compactMap { nextLegalPosition(position: emptyPosition, direction: $0) }
        let lastMoves = zip(movableTiles, moves.map { Direction.oppositeDirection(from: $0) } )
        let stateTiles = lastMoves.map({ moveTile(tiles: state.tiles, on: $0, move: $1) })
        
        return zip(stateTiles, lastMoves).map({ State(tiles: $0, lastMove: $1, previousState: state, cost: state.cost + PuzzleViewController.cost(state1: state.tiles, state2: $0)) })
    }
    
    private func allMoves(on position: (Int, Int)) -> [Direction] {
        let possibleDirections: [Direction] = [.left, .right, .up, .down]
        var legalMoves: [Direction] = []
        
        for direction in possibleDirections {
            guard nextLegalPosition(position: position, direction: direction) != nil else { continue }
            legalMoves.append(direction)
        }
        
        return legalMoves
    }
    
    private func position(of tile: Tile, tiles: [[Tile]]) -> (Int, Int)? {
        for i in 0..<3 {
            for j in 0..<3 {
                if tiles[i][j] == tile {
                    return (i, j)
                }
            }
        }
        return nil
    }
    
    private func nextLegalPosition(position: (Int, Int), direction: Direction) -> (Int, Int)? {
        let nextPosition: (Int, Int)
        switch direction {
        case .left:
            nextPosition = (position.0, position.1 - 1)
        case .right:
            nextPosition = (position.0, position.1 + 1)
        case .up:
            nextPosition = (position.0 - 1, position.1)
        case .down:
            nextPosition = (position.0 + 1, position.1)
        }
        
        return isLegalPosition(position: nextPosition) ? nextPosition : nil
    }
    
    private func isLegalPosition(position: (Int, Int)) -> Bool {
        return position.0 >= 0 && position.1 >= 0 && position.0 < 3 && position.1 < 3
    }
    
    private func moveTile(tiles: [[Tile]], on position: (Int, Int), move direction: Direction) -> [[Tile]] {
        guard let nextPosition = nextLegalPosition(position: position, direction: direction) else { return [] }
        
        var allTiles = tiles
        let tmp = tiles[position.0][position.1]
        
        allTiles[position.0][position.1] = tiles[nextPosition.0][nextPosition.1]
        allTiles[nextPosition.0][nextPosition.1] = tmp
        
        return allTiles
    }
    
    private func reconstructPath(state: State) -> [((Int, Int), Direction)] {
        var node = state
        var moves: [((Int, Int), Direction)] = []
        
        while node.lastMove != nil {
            guard let move = node.lastMove, let previous = node.previousState else { continue }
            moves.append(move)
            node = previous
        }
        
        moves.reverse()
        print(moves)
        return moves
    }
}

extension PuzzleViewController: PuzzleViewDelegate {
    
    func puzzleViewDidInitialize(state: [[Tile]]) {
        let initialState = State(tiles: state, lastMove: nil, previousState: nil, cost: 0)
        open.append(initialState)
        currentState = initialState
        solveButton.isEnabled = true
    }
    
    func puzzleViewDidChangeState(state: [[Tile]]) {
        let currentState = State(tiles: state, lastMove: nil, previousState: nil, cost: 0)
        self.currentState = currentState
    }
}
