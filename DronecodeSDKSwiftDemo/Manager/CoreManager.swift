//
//  CoreManager.swift
//  DronecodeSDKSwiftDemo
//
//  Created by Marjory Silvestre on 20.04.18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import Foundation
import Dronecode_SDK_Swift
import MFiAdapter
import RxSwift

class CoreManager {
    
    // MARK: - Properties
    
    // Telemetry
    var telemetry = Telemetry(address: "localhost", port: 50051)
    // Action
    let action = Action(address: "localhost", port: 50051)
    // Mission
    let mission = Mission(address: "localhost", port: 50051)
    
    // Core System
    let core: Core
    
    // Drone state
    let droneState = DroneState()
    
    
    private static var sharedCoreManager: CoreManager = {
        let coreManager = CoreManager()
        
        return coreManager
    }()
    
    
    // Initialization
    
    private init() {
        core = Core()
        MFiAdapter.MFiConnectionStateAdapter.sharedInstance().startMonitorConnectionState()
    }
    
    deinit {
        MFiAdapter.MFiConnectionStateAdapter.sharedInstance().stopMonitorConnectionState()
    }
    
    // MARK: - Accessors
    
    class func shared() -> CoreManager {
        return sharedCoreManager
    }
    
    public func start() -> Void {
        _ = core.connect().subscribe(onCompleted: {
            print("Core connected")
        }) { (error) in
            print("Failed connect to core with error: \(error.localizedDescription)")
        }
    }
    

    
}