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
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning),
            HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
            HKQuantityType.quantityType(forIdentifier: .flightsClimbed),
            HKQuantityType.quantityType(forIdentifier: .bodyMass),
            HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage),
            HKQuantityType.quantityType(forIdentifier: .bodyMassIndex),
            HKQuantityType.quantityType(forIdentifier: .height),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis),
            HKQuantityType.quantityType(forIdentifier: .heartRate),
            HKQuantityType.quantityType(forIdentifier: .bloodGlucose),
            HKQuantityType.quantityType(forIdentifier: .respiratoryRate),
            // HKQuantityType.quantityType(forIdentifier: .uvExposure)
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
                        "date": self.formatDate(sample.startDate)
                    ])
                }
            }
            results["stepCount"] = stepData
            dispatchGroup.leave()
        }
        healthStore.execute(stepsQuery)

        // Fetch distance walking/running
        dispatchGroup.enter()
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let distanceQuery = HKSampleQuery(sampleType: distanceType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var distanceData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    distanceData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit.meter()),
                        "date": self.formatDate(sample.startDate)
                    ])
                }
            }
            results["distanceWalkingRunning"] = distanceData
            dispatchGroup.leave()
        }
        healthStore.execute(distanceQuery)
        
        // Fetch basal energy burned
        dispatchGroup.enter()
        let basalEnergyType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
        let basalEnergyQuery = HKSampleQuery(sampleType: basalEnergyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var basalEnergyData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    basalEnergyData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit.kilocalorie()),
                        "date": self.formatDate(sample.startDate)
                    ])
                }
            }
            results["basalEnergyBurned"] = basalEnergyData
            dispatchGroup.leave()
        }
        healthStore.execute(basalEnergyQuery)
        
        // Fetch active energy burned
        dispatchGroup.enter()
        let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let activeEnergyQuery = HKSampleQuery(sampleType: activeEnergyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var activeEnergyData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    activeEnergyData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit.kilocalorie()),
                        "date": self.formatDate(sample.startDate)
                    ])
                }
            }
            results["activeEnergyBurned"] = activeEnergyData
            dispatchGroup.leave()
        }
        healthStore.execute(activeEnergyQuery)
        
        // Fetch flights climbed
        dispatchGroup.enter()
        let flightsClimbedType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed)!
        let flightsClimbedQuery = HKSampleQuery(sampleType: flightsClimbedType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var flightsClimbedData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    flightsClimbedData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit.count()),
                        "date": self.formatDate(sample.startDate)
                    ])
                }
            }
            results["flightsClimbed"] = flightsClimbedData
            dispatchGroup.leave()
        }
        healthStore.execute(flightsClimbedQuery)
        
        // Fetch body mass (weight)
        dispatchGroup.enter()
        let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let bodyMassQuery = HKSampleQuery(sampleType: bodyMassType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var bodyMassData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    bodyMassData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)),
                        "date": self.formatDate(sample.startDate)
                    ])
                }
            }
            results["bodyMass"] = bodyMassData
            dispatchGroup.leave()
        }
        healthStore.execute(bodyMassQuery)
        
        // Fetch body fat percentage
        dispatchGroup.enter()
        let bodyFatPercentageType = HKQuantityType.quantityType(forIdentifier: .bodyFatPercentage)!
        let bodyFatPercentageQuery = HKSampleQuery(sampleType: bodyFatPercentageType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var bodyFatPercentageData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    bodyFatPercentageData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit.percent()),
                        "date": self.formatDate(sample.startDate)
                    ])
                }
            }
            results["bodyFatPercentage"] = bodyFatPercentageData
            dispatchGroup.leave()
        }
        healthStore.execute(bodyFatPercentageQuery)
        
        // Fetch body mass index (BMI)
        dispatchGroup.enter()
        let bodyMassIndexType = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex)!
        let bodyMassIndexQuery = HKSampleQuery(sampleType: bodyMassIndexType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var bodyMassIndexData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    bodyMassIndexData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit.count()),
                        "date": self.formatDate(sample.startDate)
                    ])
                }
            }
            results["bodyMassIndex"] = bodyMassIndexData
            dispatchGroup.leave()
        }
        healthStore.execute(bodyMassIndexQuery)
        
        // Fetch height
        dispatchGroup.enter()
        let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
        let heightQuery = HKSampleQuery(sampleType: heightType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var heightData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    heightData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit.meter()),
                        "date": self.formatDate(sample.startDate)
                    ])
                }
            }
            results["height"] = heightData
            dispatchGroup.leave()
        }
        healthStore.execute(heightQuery)
        
        // Fetch sleep duration
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
                    } else if sample.value == HKCategoryValueSleepAnalysis.awake.rawValue {
                        sleepState = "Awake"
                    }
                    sleepData.append([
                        "state": sleepState,
                        "startDate": self.formatDate(sample.startDate),
                        "endDate": self.formatDate(sample.endDate)
                    ])
                }
            }
            results["sleepDuration"] = sleepData
            dispatchGroup.leave()
        }
        healthStore.execute(sleepQuery)
        
        // Fetch heart rate
        dispatchGroup.enter()
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var heartRateData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    heartRateData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit(from: "count/min")),
                        "date": self.formatDate(sample.startDate)
                    ])
                }
            }
            results["heartRate"] = heartRateData
            dispatchGroup.leave()
        }
        healthStore.execute(heartRateQuery)
        
        // Fetch blood glucose
        dispatchGroup.enter()
        let bloodGlucoseType = HKQuantityType.quantityType(forIdentifier: .bloodGlucose)!
        let bloodGlucoseQuery = HKSampleQuery(sampleType: bloodGlucoseType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var bloodGlucoseData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    bloodGlucoseData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit(from: "mg/dL")),
                        "date": self.formatDate(sample.startDate)
                    ])
                }
            }
            results["bloodGlucose"] = bloodGlucoseData
            dispatchGroup.leave()
        }
        healthStore.execute(bloodGlucoseQuery)
        
        // Fetch respiratory rate
        dispatchGroup.enter()
        let respiratoryRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!
        let respiratoryRateQuery = HKSampleQuery(sampleType: respiratoryRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                return
            }
            var respiratoryRateData = [[String: Any]]()
            if let quantitySamples = samples as? [HKQuantitySample] {
                for sample in quantitySamples {
                    respiratoryRateData.append([
                        "value": sample.quantity.doubleValue(for: HKUnit(from: "count/min")),
                        "date": self.formatDate(sample.startDate)
                    ])
                }
            }
            results["respiratoryRate"] = respiratoryRateData
            dispatchGroup.leave()
        }
        healthStore.execute(respiratoryRateQuery)
        
        // Wait for all queries to finish
        dispatchGroup.notify(queue: DispatchQueue.main) {
            result(results)
        }
    }
    
    private func requestAuthorization(result: @escaping FlutterResult) {
        let typesToRead: Set<HKObjectType> = Set([
            HKObjectType.quantityType(forIdentifier: .stepCount),
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            HKObjectType.quantityType(forIdentifier: .flightsClimbed),
            HKObjectType.quantityType(forIdentifier: .bodyMass),
            HKObjectType.quantityType(forIdentifier: .bodyFatPercentage),
            HKObjectType.quantityType(forIdentifier: .bodyMassIndex),
            HKObjectType.quantityType(forIdentifier: .height),
            HKObjectType.quantityType(forIdentifier: .heartRate),
            HKObjectType.quantityType(forIdentifier: .bloodGlucose),
            HKObjectType.quantityType(forIdentifier: .respiratoryRate),
            // HKObjectType.quantityType(forIdentifier: .uvExposure),
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)
        ].compactMap { $0 })
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            if success {
                result("Authorization granted")
            } else {
                result(FlutterError(code: "AUTH_ERROR", message: error?.localizedDescription ?? "Authorization failed", details: nil))
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime,.withFractionalSeconds]
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
}
