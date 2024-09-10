import Flutter
import UIKit
import HealthKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    // Declaring healthStore
    let healthStore = HKHealthStore()  
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let healthChannel = FlutterMethodChannel(name: "com.apple_health_poc", binaryMessenger: controller.binaryMessenger)
        
        healthChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard let strongSelf = self else {
                result(FlutterError(code: "UNAVAILABLE", message: "AppDelegate is not available", details: nil))
                return
            }

            if call.method == "requestAuthorization" {
                strongSelf.requestAuthorization(result: result)
            } else if call.method == "fetchHealthData" {
                guard let args = call.arguments as? [String: Any],
                      let dataType = args["dataType"] as? String else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Data type not provided", details: nil))
                    return
                }
                strongSelf.fetchHealthData(dataType: dataType, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func fetchHealthData(dataType: String,result: @escaping FlutterResult){
        guard HKHealthStore.isHealthDataAvailable() else{
            result(FlutterError(code: "Error", message: "Health data is not available", details: nil))
            return
        }
        
        let healthDataTypes = [
            "steps": HKQuantityType.quantityType(forIdentifier: .stepCount),
            "sleep_asleep": HKCategoryType.categoryType(forIdentifier: .sleepAnalysis),
            "activeEnergyBurned" : HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
        ]
        
        guard let healthType = healthDataTypes[dataType] else {
            result(FlutterError(code: "ERROR", message: "Unknown data type", details: nil))
            return
        }
        
        // Getting a weeks health data
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        let endDate = Date()
        
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        
        
        // Mapping sleep data
        if dataType == "sleep" {
            guard let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) else {
                result(FlutterError(code: "ERROR", message: "Sleep data type not available", details: nil))
                return
            }
            
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
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
                
                result(["sleepData": sleepData])
            }
            
            healthStore.execute(query)
        } else {
            guard let healthType = healthDataTypes[dataType] else {
                       result(FlutterError(code: "ERROR", message: "Unknown data type", details: nil))
                       return
                   }

                   let query = HKSampleQuery(sampleType: healthType!, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                       if let error = error {
                           result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                           return
                       }

                       var data = [String: Any]()
                       if let quantitySamples = samples as? [HKQuantitySample] {
                           data["count"] = quantitySamples.count
                           data["values"] = quantitySamples.map { sample in
                               return [
                                   "value": sample.quantity.doubleValue(for: HKUnit.count()),  // Use appropriate unit based on dataType
                                   "date": sample.startDate.description
                               ]
                           }
                       }
                       result(data)
                   }

                   healthStore.execute(query)
        }
    }
    
  private func requestAuthorization(result: @escaping FlutterResult) {
    let typesToRead: Set<HKObjectType> = Set([
        HKObjectType.quantityType(forIdentifier: .stepCount),
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
    ].compactMap { $0 })  // Using compactMap to safely unwrap optionals
    
    healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
        if success {
            result("Authorization granted")
        } else {
            result(FlutterError(code: "AUTH_ERROR", message: error?.localizedDescription ?? "Authorization failed", details: nil))
        }
    }
  }
}
