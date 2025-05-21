//
//  HealthManager.swift
//  Gomu
//
//  Created by Asad on 08/04/25.
//

import HealthKit

class HealthManager {
    private let healthStore = HKHealthStore()

//    @Published var currentHeartRate: Double = 0.0
//    @Published var totalDistance: Double = 0.0

    private var heartRateQuery: HKAnchoredObjectQuery?
    private var caloriesQuery: HKAnchoredObjectQuery?
    private var anchor: HKQueryAnchor? = nil
//    private var distanceQuery: HKAnchoredObjectQuery?

    init() {
        self.requestAuthorization { success in
            print("helthKit authorization success")
        }
    }
    
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]

        let readTypes: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]

        healthStore.requestAuthorization(toShare: typesToShare, read: readTypes) { success, error in
            completion(success)
        }
    }
    
    // ============ HEART RATE ===========
    func startHeartRateUpdates(callback: @escaping (Int) -> Void){
        guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else {return }
        
        heartRateQuery = HKAnchoredObjectQuery(type: type, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { _, samples, _, _, _ in
            self.processHeartRate(samples: samples, callback: callback)
        }

        heartRateQuery?.updateHandler = { _, samples, _, _, _ in
            self.processHeartRate(samples: samples, callback: callback)
        }

        if let query = heartRateQuery {
            healthStore.execute(query)
        }
    }
    
    func processHeartRate(samples: [HKSample]?, callback: @escaping (Int) -> Void) {
        guard let quantitySamples = samples as? [HKQuantitySample] else { return }
        guard let lastSample = quantitySamples.last else { return }

        let value = lastSample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        DispatchQueue.main.async {
            callback(Int(value))
        }
    }
    
    // ========== CALORIES =============
    func startCaloriesUpdates(start: Date, callback: @escaping (Int) -> Void) {
        var now = Date()
        guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)
        
        caloriesQuery = HKAnchoredObjectQuery(type: type, predicate: predicate, anchor: nil, limit: HKObjectQueryNoLimit) { _, samples, _, _, _ in
            self.processCalories(samples: samples, callback: callback)
        }
        
        caloriesQuery?.updateHandler = { _, samples, _, _, _ in
            self.processCalories(samples: samples, callback: callback)
        }
        
        if let query = caloriesQuery {
            healthStore.execute(query)
        }
    }
    
    func processCalories(samples: [HKSample]?, callback: @escaping (Int) -> Void) {
        guard let quantitySamples = samples as? [HKQuantitySample] else { return }
        let total = quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: .kilocalorie()) }

        DispatchQueue.main.async {
            callback(Int(total))
        }
    }
    
    func stopHealthKitUpdates() {
        if let heartRateQuery = heartRateQuery {
            healthStore.stop(heartRateQuery)
        }
        if let caloriesQuery = caloriesQuery {
            healthStore.stop(caloriesQuery)
        }

        heartRateQuery = nil
        caloriesQuery = nil
    }

}
