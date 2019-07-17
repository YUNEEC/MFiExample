//
//  CoreManager.swift
//  DronecodeSDKSwiftDemo
//
//  Created by Marjory Silvestre on 20.04.18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import Foundation
import MAVSDK_Swift
import MFiAdapter
import RxSwift

class CoreManager {
    
    let disposeBag = DisposeBag()
    
    // MARK: - Properties
    
//    // Telemetry
//    let telemetry = Telemetry(address: "localhost", port: 50051)
//    // Action
//    let action = Action(address: "localhost", port: 50051)
//    // Mission
//    let mission = Mission(address: "localhost", port: 50051)
//    // Camera
//    let camera = Camera(address: "localhost", port: 50051)
//    // Info
//    let info = Info(address: "localhost", port: 50051)
    
    // Core System
    let drone: Drone
    
    // Drone state
    let droneState = DroneState()
    
    private static var sharedCoreManager: CoreManager = {
        let coreManager = CoreManager()
        
        return coreManager
    }()
    
    
    // Initialization
    
    private init() {
        self.drone = Drone()
        DispatchQueue.global().async {
            MFiAdapter.MFiConnectionStateAdapter.sharedInstance().startMonitorConnectionState()
            MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().startMonitorRCEvent()
        }
    }
    
    deinit {
        MFiAdapter.MFiConnectionStateAdapter.sharedInstance().stopMonitorConnectionState()
    }
    
    // MARK: - Accessors
    
    class func shared() -> CoreManager {
        return sharedCoreManager
    }
    
    public func start() -> Void {
//        core.connect()
//            .subscribe(onCompleted: {
//                print("Core connected")
//            }) { (error) in
//                print("Failed connect to core with error: \(error.localizedDescription)")
//            }
//            .disposed(by: disposeBag)
        drone.startMavlink
            .subscribe(onCompleted: {
                print("+DC+ Mavlink Started.")
            }, onError: { (error) in
                print("Error starting Mavlink: \(error)")
            })
            .disposed(by: disposeBag)
        
    }
}
