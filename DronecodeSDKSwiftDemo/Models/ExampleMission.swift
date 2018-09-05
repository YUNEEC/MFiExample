//
//  ExampleMission.swift
//  DronecodeSDKSwiftDemo
//
//  Created by Marjory Silvestre on 26.04.18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import Foundation
import Dronecode_SDK_Swift
import MapKit

class ExampleMission {
    
    var missionItems = [MissionItem]()

    init(){
        
        if missionItems.isEmpty {
            missionItems = [MissionItem]()
            
//            do {
//                let entry = MissionItem(latitudeDeg: 47.398039859999997, longitudeDeg: 8.5455725400000002, relativeAltitudeM: 10.0, speedMPS: 2.0, isFlyThrough: true, gimbalPitchDeg: -60.0, gimbalYawDeg: -90.0, cameraAction: CameraAction.startPhotoInterval)
//                missionItems.append(entry)
//            }
//            do {
//                let entry = MissionItem(latitudeDeg: 47.398039859999997, longitudeDeg: 8.5455725400000002, relativeAltitudeM: 10.0, speedMPS: 2.0, isFlyThrough: true, gimbalPitchDeg: -60.0, gimbalYawDeg: -90.0, cameraAction: CameraAction.startPhotoInterval)
//                missionItems.append(entry)
//            }
//            do {
//                let entry = MissionItem(latitudeDeg: 47.398039859999997, longitudeDeg: 8.5455725400000002, relativeAltitudeM: 10.0, speedMPS: 10.0, isFlyThrough: true, gimbalPitchDeg: -60.0, gimbalYawDeg: -90.0, cameraAction: CameraAction.startPhotoInterval)
//                missionItems.append(entry)
//            }
//            do {
//                let entry = MissionItem(latitudeDeg: 47.398036222362471, longitudeDeg: 8.5450146439425509, relativeAltitudeM: 10.0, speedMPS: 10.0, isFlyThrough: true, gimbalPitchDeg: -30.0, gimbalYawDeg: 0, cameraAction: CameraAction.stopPhotoInterval)
//                missionItems.append(entry)
//            }
//            do {
//                let entry = MissionItem(latitudeDeg: 47.397825620791885, longitudeDeg: 8.5450092830163271, relativeAltitudeM: 10.0, speedMPS: 10.0, isFlyThrough: true, gimbalPitchDeg: -60.0, gimbalYawDeg: -60.0, cameraAction: CameraAction.startVideo)
//                missionItems.append(entry)
//            }
//            do {
//                let entry = MissionItem(latitudeDeg: 47.397832880000003, longitudeDeg: 8.5455939999999995, relativeAltitudeM: 10.0, speedMPS: 10.0, isFlyThrough: true, gimbalPitchDeg: 0.0, gimbalYawDeg: 0.0, cameraAction: CameraAction.stopVideo)
//                missionItems.append(entry)
//            }
            
            
            // Anotacao: Panorama - latitudeDeg: 37.8728883333333, longitudeDeg: -122.303321666667,
            
            var gimbalAngle = 0
            
            let NUMBER_OF_ROTATIONS = 12
            let ROTATION_ANGLE = 30
            
            for i in 0..<NUMBER_OF_ROTATIONS {
                
                var yawAngle = Float(Float(ROTATION_ANGLE) * Float(i))

                if (yawAngle > 180) { //Filter the angle between -180 ~ 0, 0 ~ 180
                    yawAngle -= 360
                }
                
                do {
                    let entry = MissionItem(latitudeDeg: 47.397832880000003,
                                            longitudeDeg: 8.5455939999999995,
                                            relativeAltitudeM: 15.0,
                                            speedMPS: 0.5,
                                            isFlyThrough: false,
                                            gimbalPitchDeg: Float(gimbalAngle),
                                            gimbalYawDeg: yawAngle,
                                            loiterTimeS: 2,
                                            cameraAction: CameraAction.none)
                    missionItems.append(entry)
                }
                

                for j in 0..<4 {
                    
                    do {
                        let entry = MissionItem(latitudeDeg: 47.397832880000003,
                                                longitudeDeg: 8.5455939999999995,
                                                relativeAltitudeM: 15.0,
                                                speedMPS: 0.5,
                                                isFlyThrough: false,
                                                gimbalPitchDeg: Float(gimbalAngle),
                                                gimbalYawDeg: yawAngle,
                                                loiterTimeS: 2,
                                                cameraAction: CameraAction.takePhoto)
                        missionItems.append(entry)
                    }

                    if j < 3 {
                        if i % 2 == 0 {
                            gimbalAngle -= 22
                        } else {
                            gimbalAngle += 22
                        }
                    }
                }
                
                if (yawAngle == 0 || yawAngle == 180 || yawAngle == 360) {
                    do {
                        let entry = MissionItem(latitudeDeg: 47.397832880000003,
                                                longitudeDeg: 8.5455939999999995,
                                                relativeAltitudeM: 15.0,
                                                speedMPS: 0.5,
                                                isFlyThrough: false,
                                                gimbalPitchDeg: Float(-90),
                                                gimbalYawDeg: yawAngle,
                                                loiterTimeS: 2,
                                                cameraAction: CameraAction.takePhoto)
                        missionItems.append(entry)
                    }
                    
                }
            }
        }
        
        print("Anotacao: \(missionItems)")
        
    }
    
    func  generateSampleMissionForLocation(location: CLLocation) {
        missionItems = [MissionItem]()
        
        //width and height for a single U mission : in meters
        let width: Double = 40
        let height: Double = 20
        
        // first location of the mission is equal to location in param at 10 meters of altitude
        let location1: CLLocation = location
        do {
            let entry = MissionItem(latitudeDeg: location1.coordinate.latitude,
                                    longitudeDeg:  location1.coordinate.longitude,
                                    relativeAltitudeM: 10.0,
                                    speedMPS: 2.0,
                                    isFlyThrough: true,
                                    gimbalPitchDeg: -60.0,
                                    gimbalYawDeg: -90.0,
                                    loiterTimeS: 0,
                                    cameraAction: CameraAction.startPhotoInterval)
            missionItems.append(entry)
        }
        // second location : first location at "width" meters in west direction
        let location2 = self.computeLocation(locationInit: location1, withRadius: width, withBearing: 270)
        do {
            let entry = MissionItem(latitudeDeg: location2.coordinate.latitude,
                                    longitudeDeg: location2.coordinate.longitude,
                                    relativeAltitudeM: 10.0,
                                    speedMPS: 2.0,
                                    isFlyThrough: true,
                                    gimbalPitchDeg: -60.0,
                                    gimbalYawDeg: -90.0,
                                    loiterTimeS: 0,
                                    cameraAction: CameraAction.startPhotoInterval)
            missionItems.append(entry)
        }
        // third location : second location at "height" meters in south direction
        let location3 = self.computeLocation(locationInit: location2, withRadius: height, withBearing: 180)
        do {
            let entry = MissionItem(latitudeDeg: location3.coordinate.latitude,
                                    longitudeDeg: location3.coordinate.longitude,
                                    relativeAltitudeM: 10.0,
                                    speedMPS: 10.0,
                                    isFlyThrough: true,
                                    gimbalPitchDeg: -60.0,
                                    gimbalYawDeg: -90.0,
                                    loiterTimeS: 0,
                                    cameraAction: CameraAction.startPhotoInterval)
            missionItems.append(entry)
        }
        // fourth location : third location at "width" meters in east direction
        let location4 = self.computeLocation(locationInit: location3, withRadius: width, withBearing: 90)
        do {
            let entry = MissionItem(latitudeDeg: location4.coordinate.latitude,
                                    longitudeDeg: location4.coordinate.longitude,
                                    relativeAltitudeM: 10.0,
                                    speedMPS: 10.0,
                                    isFlyThrough: true,
                                    gimbalPitchDeg: -30.0,
                                    gimbalYawDeg: 0,
                                    loiterTimeS: 0,
                                    cameraAction: CameraAction.stopPhotoInterval)
            missionItems.append(entry)
        }
    }
    
    // calculate new location from one location with distance in meters and bearing
    func computeLocation(locationInit: CLLocation, withRadius radius: Double, withBearing bearing: Double) -> CLLocation {
        let earthRadius: Double = 6371000
        let bearingRadius: Double = ((.pi * bearing) / 180)
        let latitudeRadius: Double = ((.pi * (locationInit.coordinate.latitude)) / 180)
        let longitudeRadius: Double = ((.pi * (locationInit.coordinate.longitude)) / 180)
        let computedLatitude: Double = asin(sin(latitudeRadius) * cos(radius / earthRadius) + cos(latitudeRadius) * sin(radius / earthRadius) * cos(bearingRadius))
        let computedLongitude: Double = longitudeRadius + atan2(sin(bearingRadius) * sin(radius / earthRadius) * cos(latitudeRadius), cos(radius / earthRadius) - sin(latitudeRadius) * sin(computedLatitude))
        let computedLoc = CLLocation(latitude: ((computedLatitude) * (180.0 / .pi)), longitude: ((computedLongitude) * (180.0 / .pi)))
        
        return computedLoc
    }

}
