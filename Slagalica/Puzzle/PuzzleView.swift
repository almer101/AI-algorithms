//
//  PuzzleView.swift
//  Slagalica
//
//  Created by Ivan Almer on 08/08/2019.
//  Copyright © 2019 ialmer. All rights reserved.
//

import UIKit

enum Tile: Hashable { // Hashable inherits from Equatable protocol
    case empty
    case value(Int)
    
    static func ==(lhs: Tile, rhs: Tile) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case let (.value(lhsValue), .value(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

enum Direction: Hashable {
    case left
    case right
    case up
    case down
    
    public static func oppositeDirection(from direction: Direction) -> Direction {
        switch direction {
        case .left:
            return .right
        case .right:
            return .left
        case .up:
            return .down
        case .down:
            return .up
        }
    }
}

protocol PuzzleViewDelegate: class {
    
    func puzzleViewDidInitialize(state: [[Tile]])
    func puzzleViewDidChangeState(state: [[Tile]])
}

/// 3x3 Puzzle with 8 tiles and 1 missing
class PuzzleView: UIView {
    
    /// (height, width)
    private let puzzleSize = (3, 3)
    private var tiles = [[Tile]]()
    private var tileViews: [Tile: TileView] = [:]
    
    private var edgeInsets = UIEdgeInsets.zero
    private let interItemSpacing: CGFloat = 10
    private var tileSize = CGSize.zero
    private var currentLegalMove: Direction?
    
    private var animator = UIViewPropertyAnimator()
    weak var delegate: PuzzleViewDelegate?
    
    override var frame: CGRect {
        didSet {
            updateLayoutValues()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupPuzzle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupPuzzle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // removing all views from the superview
        tileViews.values.forEach({ $0.removeFromSuperview() })
        tileViews.removeAll()
        
        backgroundColor = .clear
        
        for (i, _) in tiles.enumerated() {
            for (j, tile) in tiles[i].enumerated() {
                guard case let .value(number) = tile else { continue }
                let originX = edgeInsets.left + CGFloat(j) * (tileSize.width + interItemSpacing)
                let originY = edgeInsets.top + CGFloat(i) * (tileSize.height + interItemSpacing)
                let origin = CGPoint(x: originX, y: originY)
                
                let tileView = TileView(frame: CGRect(origin: origin, size: tileSize))
                tileView.setup(with: number , position: (i, j), delegate: self)
                tileViews[tile] = tileView
                addSubview(tileView)
            }
        }
    }
    
    private func setupPuzzle() {
        if !tiles.isEmpty {
            tiles.removeAll()
        }
        
        var fields: [Tile] = []
        let numberOfTiles = puzzleSize.0 * puzzleSize.1
        for i in 0..<numberOfTiles {
            fields.append(i == (numberOfTiles - 1) ? .empty : .value(i + 1))
        }
        
        // now tiles are arranged in goal state
        
        for i in 0..<puzzleSize.0 {
            tiles.append([])
            for j in 0..<puzzleSize.1 {
                tiles[i].append(fields[i * puzzleSize.0 + j])
            }
        }
        
        printPuzzle()
    }
    
    func shufflePuzzle(n: Int, lastEmptyPosition: (Int, Int) = (-1, -1)) {
        if n == 0 {
            delegate?.puzzleViewDidInitialize(state: tiles)
        } else if n != 0 {
            guard let emptyPosition = position(of: .empty) else { return }
            let moves = allMoves(on: emptyPosition)
            
            guard var direction = moves.randomElement(), var nextEmptyPosition = nextLegalPosition(position: emptyPosition, direction: direction) else { return }
            
            while nextEmptyPosition == lastEmptyPosition {
                guard let random = moves.randomElement(), let nextPosition = nextLegalPosition(position: emptyPosition, direction: random) else { return }
                direction = random
                nextEmptyPosition = nextPosition
            }
            
            // we have to accquire an opposite direction since we cannot move empty space, but only a concrete TileView
            let oppositeDirection = Direction.oppositeDirection(from: direction)
            
            moveTile(on: nextEmptyPosition, move: oppositeDirection) {
                self.shufflePuzzle(n: n - 1, lastEmptyPosition: emptyPosition)
            }
        }
    }
    
    func makeMoves(moves: [((Int, Int), Direction)]) {
        guard let first = moves.first else { return }
        var movesCopy = moves
        moveTile(on: first.0, move: first.1) {
            self.delegate?.puzzleViewDidChangeState(state: self.tiles)
            movesCopy.removeFirst()
            self.makeMoves(moves: movesCopy)
        }
    }
    
    private func position(of tile: Tile) -> (Int, Int)? {
        for i in 0..<puzzleSize.0 {
            for j in 0..<puzzleSize.1 {
                if tiles[i][j] == tile {
                    return (i, j)
                }
            }
        }
        return nil
    }
    
    private func printPuzzle() {
        for i in 0..<puzzleSize.0 {
            var s = ""
            for j in 0..<puzzleSize.1 {
                if case let .value(number) = tiles[i][j] {
                    s.append("\(number) ")
                } else if case .empty = tiles[i][j] {
                    s.append("  ")
                }
            }
            print(s)
        }
    }
    
    private func updateLayoutValues() {
        if frame.size.width == frame.size.height {
            edgeInsets = UIEdgeInsets.zero
        } else if frame.size.width > frame.size.height {
            let inset = (frame.size.width - frame.size.height) / 2
            edgeInsets = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        } else {
            let inset = (frame.size.height - frame.size.width) / 2
            edgeInsets = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        }
        
        let interSpace = CGFloat(puzzleSize.1 - 1) * interItemSpacing
        let availableSpace = frame.size.width - edgeInsets.left - edgeInsets.right - interSpace
        let dimension = availableSpace / CGFloat(puzzleSize.1)
        tileSize = CGSize(width: dimension, height: dimension)
        print("Tile size: \(tileSize)")
    }
    
    private func animateTileView(tileView: TileView, direction: Direction, completion: @escaping () -> Void = {} ) {
        let transform: CGAffineTransform
        
        switch direction {
        case .up:
            transform = CGAffineTransform(translationX: 0, y: -(interItemSpacing + tileSize.height))
        case .down:
            transform = CGAffineTransform(translationX: 0, y: interItemSpacing + tileSize.height)
        case .left:
            transform = CGAffineTransform(translationX: -(interItemSpacing + tileSize.width), y: 0)
        case .right:
            transform = CGAffineTransform(translationX: interItemSpacing + tileSize.width, y: 0)
        }
        
        animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeOut) {
            tileView.transform = transform
        }
        
        animator.addCompletion { _ in
            self.setNeedsLayout()
            self.layoutIfNeeded()
            completion()
        }
        
        animator.startAnimation()
    }
    
    private func legalMove(for position: (Int, Int)) -> Direction? {
        let possibleDirections: [Direction] = [.left, .right, .up, .down]
        var legalMove: Direction?
        
        for direction in possibleDirections {
            guard let nextPosition = nextLegalPosition(position: position, direction: direction) else { continue }
            if case .empty = tiles[nextPosition.0][nextPosition.1] { legalMove = direction }
        }
        
        return legalMove
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
        return position.0 >= 0 && position.1 >= 0 && position.0 < puzzleSize.0 && position.1 < puzzleSize.1
    }
    
    func moveTile(on position: (Int, Int), move direction: Direction, completion: @escaping () -> Void = {} ) {
        guard let nextPosition = nextLegalPosition(position: position, direction: direction), let tileView = tileViews[tiles[position.0][position.1]] else { return }
        let tmp = tiles[position.0][position.1]
        
        tiles[position.0][position.1] = tiles[nextPosition.0][nextPosition.1]
        tiles[nextPosition.0][nextPosition.1] = tmp
        
        animateTileView(tileView: tileView, direction: direction) {
            completion()
        }
    }
}

extension PuzzleView: TileViewDelegate {
    
    func panGestureBegan(tileView: TileView, onPosition position: (Int, Int)) {
        currentLegalMove = legalMove(for: position)
        
        guard let legalMove = currentLegalMove else { return }

        moveTile(on: position, move: legalMove) { [weak self] in
            guard let self = self else { return }
            self.delegate?.puzzleViewDidChangeState(state: self.tiles)
        }
    }
    
    func panGestureChanged(tileView: TileView, onPosition position: (Int, Int), translation: CGPoint) {
        // empty implementation for now
    }
    
    func panGestureEnded(tileView: TileView, onPosition position: (Int, Int)) {
        // empty implementation for now
    }
    
}
