//
//  CameraDefaults.swift
//  YuneecMFiExample
//
//  Created by Douglas on 8/8/18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import Foundation

protocol DronecodeCameraSettingsProtocol: CustomStringConvertible {
    static func rawValue(from description: String) -> String?
    init?(rawValue: String)
}


// Defaults = White BAlance = Auto, Exposure mode = auto, exposure compensation = 0, photo aspect ratio = 3:2, metering mode = average, color mode = enhanced, image format = jpeg, image quality = high, distortion correction = off, photo mode = single,
// Default video = video resolution = 3840 x 2160 60fps (UHD)

let defaultCameraSettings: [(DronecodeCameraSettings, String)] = [(.exposureMode, DronecodeExposureMode.auto.rawValue),
                                                                  (.whiteBalance, DronecodeWhiteBalance.auto.rawValue),
                                                                  (.exposureCompensation, DronecodeExposureCompensation.ev_0.rawValue),
                                                                  (.photoAspectRatio, DronecodePhotoAspectRatio.ratio3_2.rawValue),
                                                                  (.meteringMode, DronecodeMeteringMode.average.rawValue),
                                                                  (.colorMode, DronecodeColorMode.enhanced.rawValue),
                                                                  (.photoFormat, DronecodePhotoFormat.jpeg.rawValue),
                                                                  (.photoQuality, DronecodePhotoQuality.high.rawValue),
                                                                  (.distortionCorrection, DronecodeDistortionCorrection.off.rawValue)]

enum DronecodeCameraSettings: String {
    case colorMode = "CAM_COLORMODE"
    case exposureCompensation = "CAM_EV"
    case exposureMode = "CAM_EXPMODE"
    case distortionCorrection = "CAM_IMAGEDEWARP"
    case meteringMode = "CAM_METERING"
    case photoFormat = "CAM_PHOTOFMT"
    case photoQuality = "CAM_PHOTOQUAL"
    case photoAspectRatio = "CAM_PHOTORATIO"
    case whiteBalance = "CAM_WBMODE"
    case iso = "CAM_ISO"
    case shutterSpeed = "CAM_SHUTTERSPD"
    
    var stringValue: String {
        return rawValue
    }
    
    var settingsType: DronecodeCameraSettingsProtocol.Type {
        switch self {
        case .colorMode:
            return DronecodeColorMode.self
        case .exposureCompensation:
            return DronecodeExposureCompensation.self
        case .exposureMode:
            return DronecodeExposureMode.self
        case .distortionCorrection:
            return DronecodeDistortionCorrection.self
        case .meteringMode:
            return DronecodeMeteringMode.self
        case .photoFormat:
            return DronecodePhotoFormat.self
        case .photoQuality:
            return DronecodePhotoQuality.self
        case .photoAspectRatio:
            return DronecodePhotoAspectRatio.self
        case .whiteBalance:
            return DronecodeWhiteBalance.self
        case .shutterSpeed:
            return DronecodeShutterSpeed.self
        case .iso:
            return DronecodeISO.self
        }
    }
    
    var stringRepresentation: String {
        switch self {
        case .colorMode:
            return "Color Mode"
        case .exposureCompensation:
            return "Exposure Compensation"
        case .exposureMode:
            return "Exposure Mode"
        case .distortionCorrection:
            return "Distortion Correction"
        case .meteringMode:
            return "Metering Mode"
        case .photoFormat:
            return "Photo Format"
        case .photoQuality:
            return "Photo Quality"
        case .photoAspectRatio:
            return "Photo Aspect Ratio"
        case .whiteBalance:
            return "White Balance"
        case .iso:
            return "ISO"
        case .shutterSpeed:
            return "Sutter Speed"
        }
    }
}

enum DronecodePhotoAspectRatio: String, DronecodeCameraSettingsProtocol {
    case ratio3_2 = "1"
    case ratio4_3 = "2"
    case ratio16_9 = "3"
    
    static func rawValue(from description: String) -> String? {
        switch description {
        case DronecodePhotoAspectRatio.ratio3_2.description:
            return DronecodePhotoAspectRatio.ratio3_2.rawValue
        case DronecodePhotoAspectRatio.ratio4_3.description:
            return DronecodePhotoAspectRatio.ratio4_3.rawValue
        case DronecodePhotoAspectRatio.ratio16_9.description:
            return DronecodePhotoAspectRatio.ratio16_9.rawValue
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .ratio3_2:
            return "3:2"
        case .ratio4_3:
            return "4:3"
        case .ratio16_9:
            return "16:9"
        }
    }
}

enum DronecodeExposureCompensation: String, DronecodeCameraSettingsProtocol {
    case ev_negative3 = "-3.000000"
    case ev_negative2_5 = "-2.500000"
    case ev_negative2 = "-2.000000"
    case ev_negative1_5 = "-1.500000"
    case ev_negative1 = "-1.000000"
    case ev_negative0_5 = "-0.500000"
    case ev_0 = "0.000000"
    case ev_0_5 = "0.500000"
    case ev_1 = "1.000000"
    case ev_1_5 = "1.500000"
    case ev_2 = "2.000000"
    case ev_2_5 = "2.500000"
    case ev_3 = "3.000000"
    
    static func rawValue(from description: String) -> String? {
        switch description {
        case DronecodeExposureCompensation.ev_negative3.description:
            return DronecodeExposureCompensation.ev_negative3.rawValue
        case DronecodeExposureCompensation.ev_negative2_5.description:
            return DronecodeExposureCompensation.ev_negative2_5.rawValue
        case DronecodeExposureCompensation.ev_negative2.description:
            return DronecodeExposureCompensation.ev_negative2.rawValue
        case DronecodeExposureCompensation.ev_negative1_5.description:
            return DronecodeExposureCompensation.ev_negative1_5.rawValue
        case DronecodeExposureCompensation.ev_negative1.description:
            return DronecodeExposureCompensation.ev_negative1.rawValue
        case DronecodeExposureCompensation.ev_negative0_5.description:
            return DronecodeExposureCompensation.ev_negative0_5.rawValue
        case DronecodeExposureCompensation.ev_0.description:
            return DronecodeExposureCompensation.ev_0.rawValue
        case DronecodeExposureCompensation.ev_1.description:
            return DronecodeExposureCompensation.ev_1.rawValue
        case DronecodeExposureCompensation.ev_1_5.description:
            return DronecodeExposureCompensation.ev_1_5.rawValue
        case DronecodeExposureCompensation.ev_2.description:
            return DronecodeExposureCompensation.ev_2.rawValue
        case DronecodeExposureCompensation.ev_2_5.description:
            return DronecodeExposureCompensation.ev_2_5.rawValue
        case DronecodeExposureCompensation.ev_3.description:
            return DronecodeExposureCompensation.ev_3.rawValue
        default:
            return nil
        }
    }
    
    public var description: String {
        return self.rawValue
    }
}



enum DronecodeColorMode: String, DronecodeCameraSettingsProtocol {
    case neutral = "0"
    case enhanced = "1"
    case night = "3"
    case vivid = "5"
    case unprocessed = "2"
    
    static func rawValue(from description: String) -> String? {
        switch description {
        case DronecodeColorMode.neutral.description:
            return DronecodeColorMode.neutral.rawValue
        case DronecodeColorMode.enhanced.description:
            return DronecodeColorMode.enhanced.rawValue
        case DronecodeColorMode.night.description:
            return DronecodeColorMode.night.rawValue
        case DronecodeColorMode.vivid.description:
            return DronecodeColorMode.vivid.rawValue
        case DronecodeColorMode.unprocessed.description:
            return DronecodeColorMode.unprocessed.rawValue
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .night:
            return "Night"
        case .enhanced:
            return "Enhanced"
        case .neutral:
            return "Neutral"
        case .vivid:
            return "Vivid"
        case .unprocessed:
            return "Unprocessed"
        }
    }
}

enum DronecodeExposureMode: String, DronecodeCameraSettingsProtocol {
    case auto = "0"
    case manual = "1"
    
    static func rawValue(from description: String) -> String? {
        switch description {
        case DronecodeExposureMode.auto.description:
            return DronecodeExposureMode.auto.rawValue
        case DronecodeExposureMode.manual.description:
            return DronecodeExposureMode.manual.rawValue
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .auto:
            return "Auto"
        case .manual:
            return "Manual"
        }
    }
}

enum DronecodeDistortionCorrection: String, DronecodeCameraSettingsProtocol {
    case off = "0"
    case on = "1"
    
    static func rawValue(from description: String) -> String? {
        switch description {
        case DronecodeDistortionCorrection.off.description:
            return DronecodeDistortionCorrection.off.rawValue
        case DronecodeDistortionCorrection.on.description:
            return DronecodeDistortionCorrection.on.rawValue
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .on:
            return "On"
        case .off:
            return "Off"
        }
    }
}

enum DronecodeMeteringMode: String, DronecodeCameraSettingsProtocol {
    case average = "1"
    case center = "0"
    case spot = "2"
    
    static func rawValue(from description: String) -> String? {
        switch description {
        case DronecodeMeteringMode.average.description:
            return DronecodeMeteringMode.average.rawValue
        case DronecodeMeteringMode.center.description:
            return DronecodeMeteringMode.center.rawValue
        case DronecodeMeteringMode.spot.description:
            return DronecodeMeteringMode.spot.rawValue
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .average:
            return "Average"
        case .center:
            return "Center"
        case .spot:
            return "Spot"
        }
    }
}

enum DronecodePhotoFormat: String, DronecodeCameraSettingsProtocol {
    case jpeg = "0"
    case jpegAndDNG = "2"
    
    static func rawValue(from description: String) -> String? {
        switch description {
        case DronecodePhotoFormat.jpeg.description:
            return DronecodePhotoFormat.jpeg.rawValue
        case DronecodePhotoFormat.jpegAndDNG.description:
            return DronecodePhotoFormat.jpegAndDNG.rawValue
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .jpeg:
            return "JPEG"
        case .jpegAndDNG:
            return "JPEG + DNG"
        }
    }
}

enum DronecodePhotoQuality: String, DronecodeCameraSettingsProtocol {
    case low = "0"
    case medium = "1"
    case high = "2"
    case ultra = "3"
    
    static func rawValue(from description: String) -> String? {
        switch description {
        case DronecodePhotoQuality.low.description:
            return DronecodePhotoQuality.low.rawValue
        case DronecodePhotoQuality.medium.description:
            return DronecodePhotoQuality.medium.rawValue
        case DronecodePhotoQuality.high.description:
            return DronecodePhotoQuality.high.rawValue
        case DronecodePhotoQuality.ultra.description:
            return DronecodePhotoQuality.ultra.rawValue
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .ultra:
            return "Ultra"
        }
    }
}

enum DronecodeWhiteBalance: String, DronecodeCameraSettingsProtocol {
    case auto = "0"
    case incandescent = "1"
    case sunrise = "2"
    case sunset = "3"
    case sunny = "4"
    case cloudy = "5"
    case fluorescent = "7"
    case lock = "99"
    
    static func rawValue(from description: String) -> String? {
        switch description {
        case DronecodeWhiteBalance.auto.description:
            return DronecodeWhiteBalance.auto.rawValue
        case DronecodeWhiteBalance.incandescent.description:
            return DronecodeWhiteBalance.incandescent.rawValue
        case DronecodeWhiteBalance.sunrise.description:
            return DronecodeWhiteBalance.sunrise.rawValue
        case DronecodeWhiteBalance.sunset.description:
            return DronecodeWhiteBalance.sunset.rawValue
        case DronecodeWhiteBalance.sunny.description:
            return DronecodeWhiteBalance.sunny.rawValue
        case DronecodeWhiteBalance.cloudy.description:
            return DronecodeWhiteBalance.cloudy.rawValue
        case DronecodeWhiteBalance.fluorescent.description:
            return DronecodeWhiteBalance.fluorescent.rawValue
        case DronecodeWhiteBalance.lock.description:
            return DronecodeWhiteBalance.lock.rawValue
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .auto:
            return "Auto"
        case .incandescent:
            return "Incandescent"
        case .sunrise:
            return "Sunrise"
        case .sunset:
            return "Sunset"
        case .sunny:
            return "Sunny"
        case .cloudy:
            return "Cloudy"
        case .fluorescent:
            return "Fluorescent"
        case .lock:
            return "Lock"
        }
    }
}

enum DronecodeISO: String, DronecodeCameraSettingsProtocol {
    case iso100 = "100"
    case iso150 = "150"
    case iso200 = "200"
    case iso300 = "300"
    case iso400 = "400"
    case iso600 = "600"
    case iso800 = "800"
    case iso1600 = "1600"
    case iso3200 = "3200"
    case iso6400 = "6400"
    
    static func rawValue(from description: String) -> String? {
        switch description {
        case DronecodeISO.iso100.description:
            return DronecodeISO.iso100.rawValue
        case DronecodeISO.iso150.description:
            return DronecodeISO.iso150.rawValue
        case DronecodeISO.iso200.description:
            return DronecodeISO.iso200.rawValue
        case DronecodeISO.iso300.description:
            return DronecodeISO.iso300.rawValue
        case DronecodeISO.iso400.description:
            return DronecodeISO.iso400.rawValue
        case DronecodeISO.iso600.description:
            return DronecodeISO.iso600.rawValue
        case DronecodeISO.iso800.description:
            return DronecodeISO.iso800.rawValue
        case DronecodeISO.iso1600.description:
            return DronecodeISO.iso1600.rawValue
        case DronecodeISO.iso3200.description:
            return DronecodeISO.iso3200.rawValue
        case DronecodeISO.iso6400.description:
            return DronecodeISO.iso6400.rawValue
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .iso100:
            return "100"
        case .iso150:
            return "150"
        case .iso200:
            return "200"
        case .iso300:
            return "300"
        case .iso400:
            return "400"
        case .iso600:
            return "600"
        case .iso800:
            return "800"
        case .iso1600:
            return "1600"
        case .iso3200:
            return "3200"
        case .iso6400:
            return "6400"
        }
    }
}

enum DronecodeShutterSpeed: String, DronecodeCameraSettingsProtocol {
    case speed4 = "4.000000"
    case speed3 = "3.000000"
    case speed2 = "2.000000"
    case speed1 = "1.000000"
    case speed1_25 = "0.040000"
    case speed1_30 = "0.033333"
    case speed1_50 = "0.020000"
    case speed1_60 = "0.016666"
    case speed1_100 = "0.010000"
    case speed1_125 = "0.008000"
    case speed1_200 = "0.005000"
    case speed1_250 = "0.004000"
    case speed1_400 = "0.002500"
    case speed1_480 = "0.002083"
    case speed1_500 = "0.002000"
    case speed1_1000 = "0.001000"
    case speed1_2000 = "0.000500"
    case speed1_4000 = "0.000250"
    case speed1_8000 = "0.000125"
    
    static func rawValue(from description: String) -> String? {
        switch description {
        case DronecodeShutterSpeed.speed4.description:
            return DronecodeShutterSpeed.speed4.rawValue
        case DronecodeShutterSpeed.speed3.description:
            return DronecodeShutterSpeed.speed3.rawValue
        case DronecodeShutterSpeed.speed2.description:
            return DronecodeShutterSpeed.speed2.rawValue
        case DronecodeShutterSpeed.speed1.description:
            return DronecodeShutterSpeed.speed1.rawValue
        case DronecodeShutterSpeed.speed1_25.description:
            return DronecodeShutterSpeed.speed1_25.rawValue
        case DronecodeShutterSpeed.speed1_30.description:
            return DronecodeShutterSpeed.speed1_30.rawValue
        case DronecodeShutterSpeed.speed1_50.description:
            return DronecodeShutterSpeed.speed1_50.rawValue
        case DronecodeShutterSpeed.speed1_60.description:
            return DronecodeShutterSpeed.speed1_60.rawValue
        case DronecodeShutterSpeed.speed1_100.description:
            return DronecodeShutterSpeed.speed1_100.rawValue
        case DronecodeShutterSpeed.speed1_125.description:
            return DronecodeShutterSpeed.speed1_125.rawValue
        case DronecodeShutterSpeed.speed1_200.description:
            return DronecodeShutterSpeed.speed1_200.rawValue
        case DronecodeShutterSpeed.speed1_250.description:
            return DronecodeShutterSpeed.speed1_250.rawValue
        case DronecodeShutterSpeed.speed1_400.description:
            return DronecodeShutterSpeed.speed1_400.rawValue
        case DronecodeShutterSpeed.speed1_480.description:
            return DronecodeShutterSpeed.speed1_480.rawValue
        case DronecodeShutterSpeed.speed1_500.description:
            return DronecodeShutterSpeed.speed1_500.rawValue
        case DronecodeShutterSpeed.speed1_1000.description:
            return DronecodeShutterSpeed.speed1_1000.rawValue
        case DronecodeShutterSpeed.speed1_2000.description:
            return DronecodeShutterSpeed.speed1_2000.rawValue
        case DronecodeShutterSpeed.speed1_4000.description:
            return DronecodeShutterSpeed.speed1_4000.rawValue
        case DronecodeShutterSpeed.speed1_8000.description:
            return DronecodeShutterSpeed.speed1_1000.rawValue
        default:
            return nil
        }
    }
    
    public var description: String {
        switch self {
        case .speed4:
            return "4"
        case .speed3:
            return "3"
        case .speed2:
            return "2"
        case .speed1:
            return "1"
        case .speed1_25:
            return "1/25"
        case .speed1_30:
            return "1/30"
        case .speed1_50:
            return "1/50"
        case .speed1_60:
            return "1/60"
        case .speed1_100:
            return "1/100"
        case .speed1_125:
            return "1/125"
        case .speed1_200:
            return "1/200"
        case .speed1_250:
            return "1/250"
        case .speed1_400:
            return "1/400"
        case .speed1_480:
            return "1/480"
        case .speed1_500:
            return "1/500"
        case .speed1_1000:
            return "1/1000"
        case .speed1_2000:
            return "1/2000"
        case .speed1_4000:
            return "1/4000"
        case .speed1_8000:
            return "1/8000"
        }
    }
}
