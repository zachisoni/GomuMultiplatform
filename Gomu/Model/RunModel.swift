//
//  RunningData.swift
//  Gomu
//
//  Created by Asad on 25/03/25.
//

import SwiftData
import Foundation

@Model
public class RunModel{
    @Attribute(.unique) public var id: UUID
    var timestamp: Date
    var duration: TimeInterval
    var averagePace: String
    var distance: Double {
        didSet {
            self.calculatePace()
        }
    }
    var goal: Int
    var elevation: Double
    var avgBpm: Int
    var calories: Int
    var steps: Int
    var coordinates : [Coordinate]

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        duration: TimeInterval,
        averagePace: String = "--",
        distance: Double = 0,
        goal: Int = 0,
        elevation: Double = 0.0,
        bpm: Int = 0,
        calories: Int = 0,
        steps: Int = 0,
        coordinates: [Coordinate] = []
    ) {
        self.id = id
        self.timestamp = timestamp
        self.duration = duration
        self.averagePace = averagePace
        self.distance = distance
        self.goal = goal
        self.elevation = elevation
        self.avgBpm = bpm
        self.calories = calories
        self.steps = steps
        self.coordinates = coordinates
    }
    
    func calculatePace(){
//        var averagePace = "--"
        if self.distance == 0 {
            self.averagePace = "--"
            return
        }
        
        let distanceInMiles = self.distance / 1.6
        let paceInSeconds = self.duration / distanceInMiles
        let minutes = Int(paceInSeconds) / 60
        let seconds = Int(paceInSeconds) % 60
        if minutes >= 60 {
            self.averagePace = "--"
            return
        }
        
        self.averagePace = String(format: "%02d:%02d", minutes, seconds)
    }
}
