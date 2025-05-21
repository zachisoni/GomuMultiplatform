//
//  RunViewModel.swift
//  Gomu
//
//  Created by Franco Antonio Pranata on 26/03/25.
//

import SwiftUI
import SwiftData
import Combine
import HealthKit
import Foundation

enum RunState {
    case stopped
    case paused
    case running
}

class RunViewModel: NSObject, ObservableObject {
    @Published var runs: [RunModel] = []
    @Published var currentRun: RunModel = RunModel(id: UUID(), timestamp: Date.now, duration: 0, distance: 0, elevation: 0.0, bpm: 0, calories: 0)
    @Published var locationManager: LocationManager = LocationManager()
    @Published var runState: RunState = .stopped
    private var date: Date = Date()
    private var healthManager: HealthManager = HealthManager()
    private var timer: Timer?
    private var modelContext: ModelContext?
    private var hasPlayed1MinuteSound = false
    
    private var cancellables = Set<AnyCancellable>()
    private var soundManager = SoundRunManager.shared
    
    private let healthStore = HKHealthStore()
    #if os(watchOS)
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    #endif

//    @Published var isRunning = false
    @Published var workoutStartDate: Date?

    override init() {
        super.init()
        requestAuthorization()
        soundManager = SoundRunManager.shared
//        let data: [String: Any] = [
//            "heartRate": 120,
//            "distance": 540.5,
//            "timestamp": Date().timeIntervalSince1970
//        ]
//        WatchSessionManager.shared.send(message: data)

    }


//    init() {}

    init(context: ModelContext) {
        super.init()
        requestAuthorization()
        self.modelContext = context
        fetchRuns()
    }

    func setContext(_ context: ModelContext) {
        self.modelContext = context
        fetchRuns()
    }

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let typesToShare: Set = [
            HKObjectType.workoutType()
        ]

        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if !success {
                print("HealthKit auth failed: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    #if os(watchOS)
    func startRun() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        
        print("goal: \(currentRun.goal)")

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()

            session?.delegate = self
            builder?.delegate = self

            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                          workoutConfiguration: configuration)

            workoutStartDate = Date()
            session?.startActivity(with: workoutStartDate!)
            builder?.beginCollection(withStart: workoutStartDate!) { (success, error) in
                if !success {
                    print("Failed to begin workout collection: \(error?.localizedDescription ?? "unknown error")")
                } else {
                    DispatchQueue.main.async {
                        self.runState = .running
                    }
                }
            }
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.currentRun.duration += 1
                self.soundManager.checkAndPlay(for: self.currentRun.duration)
            }
            
        } catch {
            print("Failed to start workout: \(error.localizedDescription)")
        }
    }
    #elseif os(iOS)
    func startRun() {
        date = Date()
        locationManager = LocationManager()
        locationManager.startTracking()
        self.healthManager.startHeartRateUpdates { bpm in
            self.currentRun.avgBpm = bpm
        }
        self.healthManager.startCaloriesUpdates(start: self.date) { calories in
            self.currentRun.calories = calories
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentRun.duration += 1
            DispatchQueue.main.async {
                self.currentRun.distance = self.locationManager.calculateTotalDistance()
            }
            self.soundManager.checkAndPlay(for: self.currentRun.duration)
        }
        self.currentRun.elevation = self.locationManager.calculateElevationGain()
    }
    #endif

    #if os(watchOS)
    func pauseRun() {
        session?.pause()
        timer?.invalidate()
        timer = nil
        DispatchQueue.main.async {
            self.runState = .paused
        }
        locationManager.stopTracking()
        healthManager.stopHealthKitUpdates()
        print(self.currentRun.distance)
    }
    #elseif os(iOS)
    func pauseRun() {
        timer?.invalidate()
        timer = nil
        locationManager.stopTracking()
        healthManager.stopHealthKitUpdates()
    }
    #endif

    #if os(watchOS)
    func resumeRun() {
        session?.resume()
        DispatchQueue.main.async {
            self.runState = .running
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentRun.duration += 1
            
        }
    }
    #elseif os(iOS)
    func resumeRun() {
        locationManager.startTracking()
        self.healthManager.startHeartRateUpdates { bpm in
            self.currentRun.avgBpm = bpm
        }
        self.healthManager.startCaloriesUpdates(start: self.date) { calories in
            self.currentRun.calories = calories
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentRun.duration += 1

            DispatchQueue.main.async {
                self.currentRun.distance = self.locationManager.calculateTotalDistance()
            }

            // 🔊 Cek suara setiap detik
            SoundRunManager.shared.checkAndPlay(for: self.currentRun.duration)
        }

        self.currentRun.elevation = self.locationManager.calculateElevationGain()
    }
    #endif

    #if os(watchOS)
    func stopRun() {
        timer?.invalidate()
        timer = nil
        guard let builder = builder, let session = session else { return }
        
        guard let context = modelContext else {
            print("No model context available")
            return
        }

        session.end()
        builder.endCollection(withEnd: Date()) { (success, error) in
            builder.finishWorkout { (workout, error) in
                DispatchQueue.main.async {
                    guard let workout = workout else {
                        print("No workout returned")
                        return
                    }

                    let duration = workout.endDate.timeIntervalSince(workout.startDate)
                    let distance = self.currentRun.distance
                    let avgPace = distance > 0 ? self.currentRun.duration / (distance / 1000) : 0
                    let avgBPM = self.currentRun.avgBpm
                    let steps = self.currentRun.steps
                    let calories = self.currentRun.calories
                    let route = self.currentRun.coordinates
                    let goal = self.currentRun.goal

                    let session = RunModel(
                        timestamp: workout.startDate,
                        duration: duration,
                        averagePace: String(format: "%.2f", avgPace),
                        distance: distance,
                        goal: goal,
                        elevation: 0.0, // jika kamu belum punya data elevasi
                        bpm: avgBPM,
                        calories: calories,
                        steps: steps,
                        coordinates: route
                    )

                    context.insert(session)

                    do {
                        try context.save()
                        print("RunSession saved to SwiftData.")
                    } catch {
                        print("Failed to save RunSession: \(error)")
                    }

//                    self.resetWorkout()
                }
            }
        }
    }
    #elseif os(iOS)
    func stopRun() {
        print("trying stopping")
        timer?.invalidate()
        print("done invalidate timer")
        timer = nil
        print("done set timer to nil")
        print("done set isRunning to false")
        locationManager.stopTracking()
        print("done stopping location manager")
        healthManager.stopHealthKitUpdates()
        print("done stopping healtkit")

        guard let context = modelContext else {
            print("No model context available")
            return
        }

        let newRun = RunModel(
            timestamp: date,
            duration: currentRun.duration,
            averagePace: currentRun.averagePace,
            distance: currentRun.distance,
            elevation: currentRun.elevation,
            bpm: currentRun.avgBpm,
            calories: currentRun.calories
        )

        context.insert(newRun)

        do {
            try context.save()
            print("Run saved successfully!")
            fetchRuns()
        } catch {
            print("Failed to save run: \(error)")
        }
    }
    #endif
    
    func resetWorkout() {
        #if os(watchOS)
        session = nil
        builder = nil
        #endif
        currentRun = RunModel(id: UUID(), timestamp: Date.now, duration: 0, distance: 0, elevation: 0.0, bpm: 0, calories: 0)
        // Reset state lainnya sesuai kebutuhan kamu
    }


    func fetchRuns() {
        guard let context = modelContext else {
            print("No model context available")
            return
        }

        let descriptor = FetchDescriptor<RunModel>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        do {
            runs = try context.fetch(descriptor)
            print("Fetched \(runs.count) runs")
        } catch {
            print("Failed to fetch runs: \(error)")
        }
    }
    
    public func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}


extension RunViewModel: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        print("Workout state changed to: \(toState.rawValue)")
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error.localizedDescription)")
    }
}

#if os(watchOS)
extension RunViewModel: HKLiveWorkoutBuilderDelegate {
    
    // Set from session to model
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { return }
            let statistics = workoutBuilder.statistics(for: quantityType)

            DispatchQueue.main.async {
                if quantityType == HKQuantityType.quantityType(forIdentifier: .heartRate) {
                    let bpmUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                    let bpm = statistics?.mostRecentQuantity()?.doubleValue(for: bpmUnit) ?? 0
                    self.currentRun.avgBpm = Int(bpm)
                }

                if quantityType == HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
                    let meterUnit = HKUnit.meter()
                    let distance = statistics?.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
                    self.currentRun.distance = distance / 100
                }

                if quantityType == HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                    let kcal = statistics?.sumQuantity()?.doubleValue(for: .smallCalorie()) ?? 0
                    self.currentRun.calories = Int(kcal)
                }
                
            }
        }
    }
    
    func getStepsFromWorkout(_ workout: HKWorkout) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let predicate = HKQuery.predicateForObjects(from: workout)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let sum = result?.sumQuantity() else { return }
            let steps = sum.doubleValue(for: .count())

            DispatchQueue.main.async {
                self.currentRun.steps = Int(steps)
            }
        }

        healthStore.execute(query)
    }


    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Optional: untuk menangani events seperti pause/resume
    }
}


#endif


