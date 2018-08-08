//
//  CameraViewController.swift
//  YuneecMFiExample
//
//  Created by Douglas on 8/7/18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet weak var setPhotoModeButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var startPhotoIntervalButton: UIButton!
    @IBOutlet weak var stopPhotoIntervalButton: UIButton!
    @IBOutlet weak var setVideoModeButton: UIButton!
    @IBOutlet weak var startVideoButton: UIButton!
    @IBOutlet weak var stopVideoButton: UIButton!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var cameraStatusLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // init text for feedback and add round corner and border
        feedbackLabel.text = "Camera Response"
        feedbackLabel.layer.cornerRadius   = UI_CORNER_RADIUS_BUTTONS
        feedbackLabel?.layer.masksToBounds = true
        feedbackLabel?.layer.borderColor = UIColor.lightGray.cgColor
        feedbackLabel?.layer.borderWidth = 1.0
        
        // Set up buttons
         setPhotoModeButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
         takePhotoButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
         startPhotoIntervalButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
         stopPhotoIntervalButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
         setVideoModeButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
         startVideoButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
         stopVideoButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        
        startObserving()
    }
    
    func startObserving() {
        
        // Listen to camera mode
        let cameraModeSubscription = CoreManager.shared().camera.cameraModeObservable
            .subscribe(
                onNext:{ [weak self] mode in
                    print("Changed mode to: \(mode)")
                },
                onError: { error in
                    print("Error cameraModeSubscription: \(error.localizedDescription)")
            })
        
        
        // Listen to capture info
        let captureInfoSubscription = CoreManager.shared().camera.captureInfoObservable
            .subscribe(onNext: { [weak self] info in
//                    print("Capture info observable: \(info)")
//                let date = CameraViewController.dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(info.timeUTC/1000)))
//                let time = CameraViewController.timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(info.timeUTC)/1000))
                let infoString = "Captured success: \(info.isSuccess)\nPhoto Index: \(info.index)\nPhoto Time: \(info.timeUTC)"
                ActionsViewController.showAlert("\(infoString)",viewController:self)
                }, onError: { error in
                    print("Error captureInfoSubscription: \(error.localizedDescription)")
            })
        
        
        // Listen to camera status
        let cameraStatusSubscription = CoreManager.shared().camera.cameraStatusObservable
            .subscribe(onNext: { [weak self] status in
                    let string = " Video On: \(status.videoOn) | Photo Interval On: \(status.photoIntervalOn) | Used Storage: \(status.usedStorageMib) | Available Storage: \(status.availableStorageMib) | Total Storage \(status.totalStorageMib) | Storage Status: \(status.storageStatus.hashValue) "
                    self?.cameraStatusLabel.text = string
                }, onError: { error in
                    print("Error cameraStatusSubscription: \(error.localizedDescription)")
            })
        
        // Listen to current settings
        let currentSettingsSubscription = CoreManager.shared().camera.currentSettingsObservable
            .subscribe(onNext: { [weak self] settings in
                    print("Current settings: \(settings)")
                }, onError: { error in
                    print("Error currentSettingsSubscription: \(error.localizedDescription)")
            })
        
        
        // Listen to possible settings
        let possibleSettingOptionsSubscription = CoreManager.shared().camera.possibleSettingOptionsObservable
            .subscribe(onNext: { [weak self] settingOptions in
                    print("Possible settings: \(settingOptions)")
                }, onError: { error in
                    print("Error possibleSettingOptionsSubscription: \(error.localizedDescription)")
            })
    }
    
    
    func stopObserving() {
        
    }

    @IBAction func setPhotoMode(_ sender: UIButton) {
        let myRoutine = CoreManager.shared().camera.setMode(mode: .photo)
            .do(onError: { error in
                self.feedbackLabel.text = "Set photo mode failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Set photo mode succeeded"
            })
        _ = myRoutine.subscribe()
    }
    
    @IBAction func takePhotoPressed(_ sender: Any) {
        let myRoutine = CoreManager.shared().camera.takePhoto()
            .do(onError: { error in
                self.feedbackLabel.text = "Take photo failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Take photo succeeded"
            })
        _ = myRoutine.subscribe()
    }
    
    @IBAction func startPhotoInterval(_ sender: UIButton) {
        let myRoutine = CoreManager.shared().camera.startPhotoInteval(interval: 5)
            .do(onError: { error in
                self.feedbackLabel.text = "Start photo interval failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Start photo interval succeeded"
            })
        _ = myRoutine.subscribe()
    }
    
    @IBAction func stopPhotoInterval(_ sender: UIButton) {
        let myRoutine = CoreManager.shared().camera.stopPhotoInterval()
            .do(onError: { error in
                self.feedbackLabel.text = "Stop photo interval failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Stop photo interval succeeded"
            })
        _ = myRoutine.subscribe()
    }
    
    @IBAction func setVideoMode(_ sender: UIButton) {
        let myRoutine = CoreManager.shared().camera.setMode(mode: .video)
            .do(onError: { error in
                self.feedbackLabel.text = "Set video mode failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Set video mode succeeded"
            })
        _ = myRoutine.subscribe()
    }
    
    @IBAction func startVideo(_ sender: UIButton) {
        let myRoutine = CoreManager.shared().camera.startVideo()
            .do(onError: { error in
                self.feedbackLabel.text = "Start video failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Start video succeeded"
            })
        _ = myRoutine.subscribe()
    }
    
    @IBAction func stopVideo(_ sender: UIButton) {
        let myRoutine = CoreManager.shared().camera.stopVideo()
            .do(onError: { error in
                self.feedbackLabel.text = "Stop video failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Stop video succeeded"
            })
        _ = myRoutine.subscribe()
    }
    
}

extension CameraViewController {
    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.autoupdatingCurrent
        return formatter
    }()
    
    fileprivate static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.autoupdatingCurrent
        return formatter
    }()
}
