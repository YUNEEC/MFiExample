//
//  TelemetryEntries.swift
//  DronecodeSDKSwiftDemo
//
//  Created by Marjory Silvestre on 24.04.18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import Foundation
import RxSwift
import MapKit
import Dronecode_SDK_Swift

enum EntryType : Int {
    case connection = 0
    case health
    case altitude
    case latitude_longitude
    case armed
    case groundspeed
    case battery
    case attitude
    case cameraAttitude
    case gps
    case in_air
    case home
    case flightMode
    case rcStatus
    case entry_type_max
}

class TelemetryEntries {
    
    var entries = [TelemetryEntry]()
    let disposeBag = DisposeBag()
    
    init() {
        // Prepare entries array : index EntryType value TelemetryEntry
        if entries.isEmpty {
            entries = [TelemetryEntry](repeating:TelemetryEntry(), count:10)
            do {
                let entry = TelemetryEntry()
                entry.property = "Connection"
                entry.value = "No Connection";
                entries.insert(entry, at: EntryType.connection.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "Health"
                entries.insert(entry, at: EntryType.health.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "Relative, absolute altitude"
                entries.insert(entry, at: EntryType.altitude.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "Latitude, longitude"
                entries.insert(entry, at: EntryType.latitude_longitude.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "Armed"
                entries.insert(entry, at: EntryType.armed.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "Groundspeed velocity"
                entries.insert(entry, at: EntryType.groundspeed.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "Battery"
                entries.insert(entry, at: EntryType.battery.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "Attitude"
                entries.insert(entry, at: EntryType.attitude.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "Camera Attitude"
                entries.insert(entry, at: EntryType.cameraAttitude.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "GPS"
                entries.insert(entry, at: EntryType.gps.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "In Air"
                entries.insert(entry, at: EntryType.in_air.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "Home Position"
                entries.insert(entry, at: EntryType.home.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "Flight Mode"
                entries.insert(entry, at: EntryType.flightMode.rawValue)
            }
            do {
                let entry = TelemetryEntry()
                entry.property = "RC Status"
                entries.insert(entry, at: EntryType.rcStatus.rawValue)
            }
        }
        
        //Listen Connection
        let coreStatus: Observable<UInt64> = CoreManager.shared().core.discoverObservable
        coreStatus.subscribe(onNext: { uuid in
                self.onDiscoverObservable(uuid: uuid)
            }, onError: { error in
                print("Error Discover \(error)")
            })
            .disposed(by: disposeBag)
        
        //Listen Timeout
        let coreTimeout: Observable<Void> = CoreManager.shared().core.timeoutObservable
        coreTimeout.subscribe({Void in
                self.onTimeoutObservable()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: -
    func onDiscoverObservable(uuid:UInt64)
    {
        //UUID of connected drone 
        print("Drone Connected with UUID : \(uuid)")
        entries[EntryType.connection.rawValue].value = "Drone Connected with UUID : \(uuid)"
        entries[EntryType.connection.rawValue].state = 1
        
        //Listen Health
        let health: Observable<Health> = CoreManager.shared().telemetry.healthObservable
        health.subscribe(onNext: { health in
                //print ("Next health \(health)")
                self.onHealthUpdate(health: health)
            }, onError: { error in
                print("Error Health")
            })
            .disposed(by: disposeBag)
        
        //Listen Position
        let position: Observable<Position> = CoreManager.shared().telemetry.positionObservable
        position.subscribe(onNext: { position in
                //print ("Next Pos \(position)")
                CoreManager.shared().droneState.location2D = CLLocationCoordinate2DMake(position.latitudeDeg,position.longitudeDeg)
                self.onPositionUpdate(position: position)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen Armed
        let armed: Observable<Bool> = CoreManager.shared().telemetry.armedObservable
        armed.subscribe(onNext: { bool in
                self.onArmedUpdate(bool)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen Ground Speed
        let groundSpeed: Observable<GroundSpeedNED> = CoreManager.shared().telemetry.groundSpeedNEDObservable
        groundSpeed.subscribe(onNext: { groundSpeed in
                self.onGroundSpeedUpdate(groundSpeed)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen Battery
        let battery: Observable<Battery> = CoreManager.shared().telemetry.batteryObservable
        battery.subscribe(onNext: { battery in
                self.onBatteryUpdate(battery)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen Attitude
        let attitude: Observable<EulerAngle> = CoreManager.shared().telemetry.attitudeEulerObservable
        attitude.subscribe(onNext: { attitude in
                self.onAttitudeUpdate(attitude)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen GPS
        let gps: Observable<GPSInfo> = CoreManager.shared().telemetry.GPSInfoObservable
        gps.subscribe(onNext: { gps in
                self.onGPSUpdate(gps)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen In Air
        let inAir: Observable<Bool> = CoreManager.shared().telemetry.inAirObservable
        inAir.subscribe(onNext: { bool in
                self.onInAirUpdate(bool)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen Home Position
        let homePosition: Observable<Position> = CoreManager.shared().telemetry.homePositionObservable
        homePosition.subscribe(onNext: { position in
                self.onHomePositionUpdate(position)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen Camera Attitude
        let cameraAttitude: Observable<EulerAngle> = CoreManager.shared().telemetry.cameraAttitudeEulerObservable
        cameraAttitude.subscribe(onNext: { attitude in
                self.onCameraAttitudeUpdate(attitude)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        
        //Listen Flight Mode
        let flightMode: Observable<eDroneCoreFlightMode> = CoreManager.shared().telemetry.flightModeObservable
        flightMode
            .subscribe(onNext: { flightMode in
                self.onFlightModeUpdate(flightMode)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen RC Status
        let rcStatus: Observable<RCStatus> = CoreManager.shared().telemetry.rcStatusObservable
        rcStatus.subscribe(onNext: { rcStatus in
                self.onRCStatusUpdate(rcStatus)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
    }
    
    func onTimeoutObservable() {
        entries[EntryType.connection.rawValue].value = "Not Connected"
        entries[EntryType.connection.rawValue].state = 0
    }
    
    func onHealthUpdate(health:Health) {
        entries[EntryType.health.rawValue].value = "Calibration \(health.isAccelerometerCalibrationOk ? "Ready" : "Not OK"), GPS \(health.isLocalPositionOk ? "Ready" : "Acquiring")"
    }
    
    func onPositionUpdate(position:Position) {
        entries[EntryType.altitude.rawValue].value = "\(position.relativeAltitudeM) m, \(position.absoluteAltitudeM) m"
        
        entries[EntryType.latitude_longitude.rawValue].value = "\(position.latitudeDeg) Deg, \(position.longitudeDeg) Deg"
    }
    
    func onArmedUpdate(_ isArmed: Bool) {
        entries[EntryType.armed.rawValue].value = isArmed ? "Armed" : "Not Armed"
    }
    
    func onInAirUpdate(_ inAir: Bool) {
        entries[EntryType.in_air.rawValue].value = inAir ? "Flying" : "Not Flying"
    }
    
    func onGroundSpeedUpdate(_ groundSpeed: GroundSpeedNED) {
        entries[EntryType.groundspeed.rawValue].value = "North: \(groundSpeed.velocityNorthMS), East: \(groundSpeed.velocityEastMS), Down: \(groundSpeed.velocityDownMS)"
    }
    
    func onBatteryUpdate(_ battery: Battery) {
        entries[EntryType.battery.rawValue].value = "Remaining: \(battery.remainingPercent * 100)%, Voltage: \(battery.voltageV)"
    }
    
    func onAttitudeUpdate(_ attitude: EulerAngle) {
        entries[EntryType.attitude.rawValue].value = "Pitch: \(attitude.pitchDeg), Roll: \(attitude.rollDeg), Yaw: \(attitude.yawDeg)"
    }
    
    func onCameraAttitudeUpdate(_ attitude: EulerAngle) {
        entries[EntryType.cameraAttitude.rawValue].value = "Pitch: \(attitude.pitchDeg), Roll: \(attitude.rollDeg), Yaw: \(attitude.yawDeg)"
    }
    
    func onGPSUpdate(_ gps: GPSInfo) {
        entries[EntryType.gps.rawValue].value = "Satelites: \(gps.numSatellites)"
    }
    
    func onHomePositionUpdate(_ position: Position) {
        entries[EntryType.home.rawValue].value = "\(position.latitudeDeg) Deg, \(position.longitudeDeg) Deg"
    }
    
    func onFlightModeUpdate(_ flightMode: eDroneCoreFlightMode) {
        entries[EntryType.flightMode.rawValue].value = "\(flightMode)"
    }
    
    func onRCStatusUpdate(_ rcStatus: RCStatus) {
        var message: String
        
        if rcStatus.isAvailable {
            message = "Signal strength: \(rcStatus.signalStrengthPercent)%"
        } else if rcStatus.wasAvailableOnce{
            message = "Not available anymore"
        } else {
            message = "Not available"
        }
        
        entries[EntryType.rcStatus.rawValue].value = message
    }


    
}
