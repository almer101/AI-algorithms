//
//  AntColonyViewController.swift
//  Slagalica
//
//  Created by Ivan Almer on 13/08/2019.
//  Copyright © 2019 ialmer. All rights reserved.
//

import UIKit

class AntColonyViewController: UIViewController {

    @IBOutlet weak var pointsView: PointsView!
    
    private var locations: [CGPoint] = []
    private var ants: [Ant] = []
    private var startLocation: CGPoint?
    private var pheromones: [[Double]] = []
    private let numberOfIterations = 200
    private let numberOfAnts = 40
    private let pheromoneEvaporationCoefficient: Double = 0.2
    private let alpha: Double = 2
    
    private var shortestPath: [CGPoint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        pointsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOccured)))
    }
    
    @objc private func tapOccured(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            locations.append(recognizer.location(in: pointsView))
            pointsView.updateLocations(locations)
        default:
            break
        }
    }
    
    @IBAction func undoTapped(_ sender: UIButton) {
        _ = locations.popLast()
        pointsView.updateLocations(locations)
    }
    
    @IBAction func startTapped(_ sender: UIButton) {
        startACO()
    }
    
    private func startACO() {
        initializeAnts(numberOfAnts: numberOfAnts)
        initializePheromones()
        
        for _ in 0..<numberOfIterations {
            // make iteration
            makeIteration()
            
            // choose best ant
            guard let best = ants.min(by: { $0.pathLength() < $1.pathLength() }) else {
                fatalError("No best ant found!")
            }
            
            let len = pathLength(locations: shortestPath)
            
            if len == 0.0 {
                shortestPath = best.path
            }
            
            if Double(best.pathLength()) < len {
                shortestPath = best.path
            }
            
            // draw best path
            print(pathLength(locations: shortestPath))
            
            guard let start = startLocation else { fatalError("No start location set!") }
            ants.forEach { $0.reset(startLocation: start) }
        }
        
        pointsView.drawAntPath(path: shortestPath)
    }
    
    private func initializeAnts(numberOfAnts: Int) {
        guard let start = locations.randomElement() else { return }
        self.startLocation = start
        
        for _ in 0..<numberOfAnts {
            ants.append(Ant(allLocations: locations, startLocation: start))
        }
    }
    
    private func initializePheromones() {
        let t0 = 100 * Double(ants.count) / pathLength(locations: locations)
        for i in 0..<locations.count {
            pheromones.append([])
            for j in 0..<locations.count {
                pheromones[i].append(i == j ? 0 : t0)
            }
        }
    }
    
    private func makeIteration() {
        for ant in ants {
            for _ in 0..<locations.count {
                guard let next = chooseNextVertix(from: ant.currentLocation, unvisited: ant.unvisitedLocations) else {
                    ant.move(to: ant.currentLocation)
                    break
                }
                ant.move(to: next)
            }
        }
        ants.forEach { updatePheromones(with: $0) }
        evaporatePheromones()
    }
    
    private func chooseNextVertix(from point: CGPoint, unvisited: [CGPoint]) -> CGPoint? {
        guard let currentLocationIndex = locations.firstIndex(of: point) else {
            fatalError("The current point is not in locations array")
        }
        
        let trails = unvisited.compactMap { locations.firstIndex(of: $0) }
                    .map { pheromones[currentLocationIndex][$0] }
                    .map { pow($0, alpha) }
        let sum = trails.reduce(0.0, +)
        
        let random = Double.random(in: 0...1)
        var cumulativeSum = 0.0
        
        for i in 0..<unvisited.count {
            cumulativeSum += trails[i] / sum
            if random <= cumulativeSum { return unvisited[i] }
        }
        
        return nil
    }
    
    private func evaporatePheromones() {
        for i in 0..<pheromones.count {
            for j in 0..<pheromones[i].count {
                pheromones[i][j] = pheromones[i][j] * (1 - pheromoneEvaporationCoefficient)
            }
        }
    }
    
    private func updatePheromones(with ant: Ant) {
        let delta = Double(1000.0 / ant.pathLength())
        for i in 1..<ant.path.count {
            guard let index1 = locations.firstIndex(of: ant.path[i - 1]), let index2 = locations.firstIndex(of: ant.path[i]) else { return }
            // update both ways since all edges are bidirectional
            pheromones[index1][index2] += delta
            pheromones[index2][index1] += delta
        }
    }
    
    // should go to Util
    func pathLength(locations: [CGPoint]) -> Double {
        if locations.count == 1 || locations.count == 0 { return 0 }
        var length: Double = 0.0
        
        for i in 1..<locations.count {
            length += distance(from: locations[i-1], to: locations[i])
        }
        
        return length
    }
    
    private func distance(from point1: CGPoint, to point2: CGPoint) -> Double {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        return Double(sqrt(dx * dx + dy * dy))
    }
    
}
