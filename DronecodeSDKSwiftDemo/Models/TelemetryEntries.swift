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
    case distance
}

class TelemetryEntries {
    
    var entries = [TelemetryEntry]()
    let disposeBag = DisposeBag()
    var homePosition:CLLocation = CLLocation(latitude: 0, longitude: 0)
    
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
            do {
                let entry = TelemetryEntry()
                entry.property = "Distance In Meters"
                entries.insert(entry, at: EntryType.distance.rawValue)
            }
        }
        
        // Anotacao
        let coreStatus = CoreManager.shared().drone.core.connectionState
        coreStatus
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { connectionState in
                self.onDiscoverObservable(uuid: connectionState.uuid)
            }, onError: { error in
                print("Error Discover \(error)")
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
        //Set camera system time to current local time
        MFiAdapter.MFiCameraAdapter.sharedInstance().setCameraSystemTime()
        //Listen Health
        let health: Observable<Telemetry.Health> = CoreManager.shared().drone.telemetry.health
        health
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { health in
                //print ("Next health \(health)")
                self.onHealthUpdate(health: health)
            }, onError: { error in
                print("Error Health")
            })
            .disposed(by: disposeBag)
        
        //Listen Position
        let position: Observable<Telemetry.Position> = CoreManager.shared().drone.telemetry.position
        position
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { position in
                //print ("Next Pos \(position)")
                CoreManager.shared().droneState.location2D = CLLocationCoordinate2DMake(position.latitudeDeg,position.longitudeDeg)
                self.onPositionUpdate(position: position)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen Armed
        let armed: Observable<Bool> = CoreManager.shared().drone.telemetry.armed
        armed
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { bool in
                self.onArmedUpdate(bool)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen Ground Speed
        let groundSpeed: Observable<Telemetry.SpeedNed> = CoreManager.shared().drone.telemetry.groundSpeedNed
        groundSpeed
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { groundSpeed in
                self.onGroundSpeedUpdate(groundSpeed)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen Battery
        let battery: Observable<Telemetry.Battery> = CoreManager.shared().drone.telemetry.battery
        battery
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { battery in
                self.onBatteryUpdate(battery)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen Attitude
        let attitude: Observable<Telemetry.EulerAngle> = CoreManager.shared().drone.telemetry.attitudeEuler
        attitude
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { attitude in
                self.onAttitudeUpdate(attitude)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen GPS
        let gps: Observable<Telemetry.GpsInfo> = CoreManager.shared().drone.telemetry.gpsInfo
        gps
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { gps in
                self.onGPSUpdate(gps)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen In Air
        let inAir: Observable<Bool> = CoreManager.shared().drone.telemetry.inAir
        inAir
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { bool in
                self.onInAirUpdate(bool)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen Home Position
        let homePosition: Observable<Telemetry.Position> = CoreManager.shared().drone.telemetry.home
        homePosition
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { position in
                self.onHomePositionUpdate(position)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen Camera Attitude
        let cameraAttitude: Observable<Telemetry.EulerAngle> = CoreManager.shared().drone.telemetry.attitudeEuler
        cameraAttitude
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { attitude in
                self.onCameraAttitudeUpdate(attitude)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        
        //Listen Flight Mode
        let flightMode: Observable<Telemetry.FlightMode> = CoreManager.shared().drone.telemetry.flightMode
        flightMode
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { flightMode in
                self.onFlightModeUpdate(flightMode)
            }, onError: { error in
                print("Error telemetry")
            })
            .disposed(by: disposeBag)
        
        //Listen RC Status
        let rcStatus: Observable<Telemetry.RcStatus> = CoreManager.shared().drone.telemetry.rcStatus
        rcStatus
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { rcStatus in
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
    
    func onHealthUpdate(health: Telemetry.Health) {
        entries[EntryType.health.rawValue].value = "Calibration \(health.isAccelerometerCalibrationOk ? "Ready" : "Not OK"), GPS \(health.isLocalPositionOk ? "Ready" : "Acquiring")"
    }
    
    func onPositionUpdate(position: Telemetry.Position) {
        entries[EntryType.altitude.rawValue].value = "\(position.relativeAltitudeM) m, \(position.absoluteAltitudeM) m"
        
        entries[EntryType.latitude_longitude.rawValue].value = "\(position.latitudeDeg) Deg, \(position.longitudeDeg) Deg"
        onDistanceUpdate()
    }
    
    func onArmedUpdate(_ isArmed: Bool) {
        entries[EntryType.armed.rawValue].value = isArmed ? "Armed" : "Not Armed"
    }
    
    func onInAirUpdate(_ inAir: Bool) {
        entries[EntryType.in_air.rawValue].value = inAir ? "Flying" : "Not Flying"
    }
    
    func onGroundSpeedUpdate(_ groundSpeed: Telemetry.SpeedNed) {
        entries[EntryType.groundspeed.rawValue].value = "North: \(groundSpeed.velocityNorthMS), East: \(groundSpeed.velocityEastMS), Down: \(groundSpeed.velocityDownMS)"
    }
    
    func onBatteryUpdate(_ battery: Telemetry.Battery) {
        entries[EntryType.battery.rawValue].value = "Remaining: \(battery.remainingPercent * 100)%, Voltage: \(battery.voltageV)"
    }
    
    func onAttitudeUpdate(_ attitude: Telemetry.EulerAngle) {
        entries[EntryType.attitude.rawValue].value = "Pitch: \(attitude.pitchDeg), Roll: \(attitude.rollDeg), Yaw: \(attitude.yawDeg)"
    }
    
    func onCameraAttitudeUpdate(_ attitude: Telemetry.EulerAngle) {
        entries[EntryType.cameraAttitude.rawValue].value = "Pitch: \(attitude.pitchDeg), Roll: \(attitude.rollDeg), Yaw: \(attitude.yawDeg)"
    }
    
    func onGPSUpdate(_ gps: Telemetry.GpsInfo) {
        entries[EntryType.gps.rawValue].value = "Satelites: \(gps.numSatellites)"
    }
    
    func onHomePositionUpdate(_ position: Telemetry.Position) {
        entries[EntryType.home.rawValue].value = "\(position.latitudeDeg) Deg, \(position.longitudeDeg) Deg"
        self.homePosition = CLLocation(latitude: position.latitudeDeg, longitude: position.longitudeDeg)
        onDistanceUpdate()
    }
    
    func onFlightModeUpdate(_ flightMode: Telemetry.FlightMode) {
        entries[EntryType.flightMode.rawValue].value = "\(flightMode)"
    }
    
    func onRCStatusUpdate(_ rcStatus: Telemetry.RcStatus) {
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

    func onDistanceUpdate() {
        let distanceInMeters = homePosition.distance(from:CLLocation(latitude: CoreManager.shared().droneState.location2D.latitude,longitude: CoreManager.shared().droneState.location2D.longitude))
        entries[EntryType.distance.rawValue].value = "\(distanceInMeters)"
    }
}
