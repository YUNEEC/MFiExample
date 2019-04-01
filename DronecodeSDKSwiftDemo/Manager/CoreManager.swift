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
    
    let disposeBag = DisposeBag()
    
    // MARK: - Properties
    // Drone state
    let droneState = DroneState()
    
    // Drone
    let drone: Drone
    
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
        drone.startMavlink
            .subscribe(onCompleted: {
                print("+DC+ Mavlink Started.")
            }, onError: { (error) in
                print("Error starting Mavlink: \(error)")
            })
            .disposed(by: disposeBag)
        
        CoreManager.shared().drone.camera.cameraStatus.subscribe().disposed(by: disposeBag)
    }
}
