import Flutter
import UIKit
import HealthKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    let healthStore = HKHealthStore()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let healthChannel = FlutterMethodChannel(name: "com.apple_health_poc", binaryMessenger: controller.binaryMessenger)
        
        healthChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result:  @escaping FlutterResult) -> Void in
             if call.method == "requestAuthorization" {
                self?.requestAuthorization(result: result)
             } else if call.method == "fetchHealthData"{
                self?.fetchHealthData(result: result)
             } else {
                 result(FlutterMethodNotImplemented)
             }
        })
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func fetchHealthData(result: @escaping FlutterResult) {
        guard HKHealthStore.isHealthDataAvailable() else {
            result(FlutterError(code: "Error", message: "Health data is not available", details: nil))
            return
        }

        // Define the data types to fetch
        let healthDataTypes = Set([
            HKQuantityType.quantityType(forIdentifier: .stepCount),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        ].compactMap { $0 })
        
        // Create a query to fetch all the required data types
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        
        let dispatchGroup = DispatchGroup()
        var results: [String: Any] = [:]
        
        // Fetch steps
        dispatchGroup.enter()
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let stepsQuery = HKSampleQuery(sampleType: stepsType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var stepData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    stepData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit.count()),
                        "date": sample.startDate.description
                    ])
                }
            }
            results["steps"] = stepData
            dispatchGroup.leave()
        }
        healthStore.execute(stepsQuery)
        
        // Fetch sleep data
        dispatchGroup.enter()
        let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
        let sleepQuery = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var sleepData = [[String: Any]]()
            if let categorySamples = samples as? [HKCategorySample] {
                for sample in categorySamples {
                    var sleepState = "Unknown"
                    if sample.value == HKCategoryValueSleepAnalysis.inBed.rawValue {
                        sleepState = "In Bed"
                    } else if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue {
                        sleepState = "Asleep"
                    }
                    sleepData.append([
                        "state": sleepState,
                        "startDate": sample.startDate.description,
                        "endDate": sample.endDate.description
                    ])
                }
            }
            results["sleep"] = sleepData
            dispatchGroup.leave()
        }
        healthStore.execute(sleepQuery)
        
        // Fetch active energy burned
        dispatchGroup.enter()
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let energyQuery = HKSampleQuery(sampleType: energyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var energyData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    energyData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit.kilocalorie()),
                        "date": sample.startDate.description
                    ])
                }
            }
            results["activeEnergyBurned"] = energyData
            dispatchGroup.leave()
        }
        healthStore.execute(energyQuery)
        
        // Wait for all queries to finish
        dispatchGroup.notify(queue: DispatchQueue.main) {
            result(results)
        }
    }
    
    private func requestAuthorization(result: @escaping FlutterResult) {
        let typesToRead: Set<HKObjectType> = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount),
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
        ].compactMap { $0 })
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if success {
                result("Authorization granted")
            } else {
                result(FlutterError(code: "AUTH_ERROR", message: error?.localizedDescription ?? "Authorization failed", details: nil))
            }
        }
    }
}
