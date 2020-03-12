//
//  Ant.swift
//  Slagalica
//
//  Created by Ivan Almer on 14/08/2019.
//  Copyright © 2019 ialmer. All rights reserved.
//

import UIKit

class Ant {
    
    let id: String = UUID().uuidString
    let allLocations: [CGPoint]
    var unvisitedLocations: [CGPoint]
    var currentLocation: CGPoint
    var path: [CGPoint] = []
    
    init(allLocations: [CGPoint], startLocation: CGPoint) {
        self.allLocations = allLocations
        self.currentLocation = startLocation
        self.unvisitedLocations = allLocations
        
        guard let index = unvisitedLocations.firstIndex(of: startLocation) else { return }
        unvisitedLocations.remove(at: index)
    }
    
    func move(to location: CGPoint) {
        path.append(currentLocation)
        currentLocation = location
        
        guard let index = unvisitedLocations.firstIndex(of: location) else { return }
        unvisitedLocations.remove(at: index)
    }
    
    func reset(startLocation: CGPoint) {
        path.removeAll()
        currentLocation = startLocation
        unvisitedLocations = allLocations
        
        guard let index = unvisitedLocations.firstIndex(of: startLocation) else { return }
        unvisitedLocations.remove(at: index)
    }
    
    func pathLength() -> CGFloat {
        if path.count == 1 || path.count == 0 { return 0 }
        var length: CGFloat = 0.0
        
        for i in 1..<path.count {
           length += Ant.distance(from: path[i-1], to: path[i])
        }
        
        return length
    }
    
    private static func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        return sqrt((point1.x - point2.x)*(point1.x - point2.x) + (point1.y - point2.y)*(point1.y - point2.y))
    }
}

