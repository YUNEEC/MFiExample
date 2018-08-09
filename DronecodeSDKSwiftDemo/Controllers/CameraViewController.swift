//
//  CameraViewController.swift
//  YuneecMFiExample
//
//  Created by Douglas on 8/7/18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import UIKit
import RxSwift
import Dronecode_SDK_Swift
import Eureka

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
    @IBOutlet weak var setSettingsButton: UIButton!
    
    private let disposeBag = DisposeBag()
    
    // Anotacao
    var currentCameraSettings = Variable<[Setting]>([])
    var possibleCameraSettingOptions = Variable<[SettingOptions]>([])
    
    var globalSetting: (settingID: String?, optionID: String?)

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
         setSettingsButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        
        startObserving()
    }

    @IBAction func setPhotoMode(_ sender: UIButton) {
        setPhotoModeButton.isEnabled = false
        
        let _ = CoreManager.shared().camera.setMode(mode: .photo)
            .do(onError: { error in
                self.feedbackLabel.text = "Set photo mode failed: \(error.localizedDescription)"
                self.setPhotoModeButton.isEnabled = true
            }, onCompleted: {
                self.feedbackLabel.text = "Set photo mode succeeded"
                self.setPhotoModeButton.isEnabled = true
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func takePhotoPressed(_ sender: Any) {
        takePhotoButton.isEnabled = false
        
        let _ = CoreManager.shared().camera.takePhoto()
            .do(onError: { [weak self] error in
                self?.feedbackLabel.text = "Take photo failed: \(error.localizedDescription)"
                self?.takePhotoButton.isEnabled = true
            }, onCompleted: { [weak self] in
                self?.feedbackLabel.text = "Take photo succeeded"
                self?.takePhotoButton.isEnabled = true
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func startPhotoInterval(_ sender: UIButton) {
        startPhotoIntervalButton.isEnabled = false
        
        let _ = CoreManager.shared().camera.startPhotoInteval(interval: 5)
            .do(onError: { error in
                self.feedbackLabel.text = "Start photo interval failed: \(error.localizedDescription)"
                self.startPhotoIntervalButton.isEnabled = true
            }, onCompleted: {
                self.feedbackLabel.text = "Start photo interval succeeded"
                self.startPhotoIntervalButton.isEnabled = true
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func stopPhotoInterval(_ sender: UIButton) {
        stopPhotoIntervalButton.isEnabled = false

        let _ = CoreManager.shared().camera.stopPhotoInterval()
            .do(onError: { error in
                self.feedbackLabel.text = "Stop photo interval failed: \(error.localizedDescription)"
                self.stopPhotoIntervalButton.isEnabled = true
            }, onCompleted: {
                self.feedbackLabel.text = "Stop photo interval succeeded"
                self.stopPhotoIntervalButton.isEnabled = true
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func setVideoMode(_ sender: UIButton) {
        setVideoModeButton.isEnabled = false
        
        let _ = CoreManager.shared().camera.setMode(mode: .video)
            .do(onError: { error in
                self.feedbackLabel.text = "Set video mode failed: \(error.localizedDescription)"
                self.setVideoModeButton.isEnabled = true
            }, onCompleted: {
                self.feedbackLabel.text = "Set video mode succeeded"
                self.setVideoModeButton.isEnabled = true
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func startVideo(_ sender: UIButton) {
        startVideoButton.isEnabled = false
        
        let _ = CoreManager.shared().camera.startVideo()
            .do(onError: { error in
                self.feedbackLabel.text = "Start video failed: \(error.localizedDescription)"
                self.startVideoButton.isEnabled = true
            }, onCompleted: {
                self.feedbackLabel.text = "Start video succeeded"
                self.startVideoButton.isEnabled = true
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func stopVideo(_ sender: UIButton) {
        stopVideoButton.isEnabled = false
        
        let _ = CoreManager.shared().camera.stopVideo()
            .do(onError: { error in
                self.feedbackLabel.text = "Stop video failed: \(error.localizedDescription)"
                self.stopVideoButton.isEnabled = true
            }, onCompleted: {
                self.feedbackLabel.text = "Stop video succeeded"
                self.stopVideoButton.isEnabled = true
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func setSettings(_ sender: UIButton) {
        
        openSettings()
        
        // Anotacao: Setting first random settings.
//        guard let settingID = globalSetting.settingID, let optionID = globalSetting.optionID else {
//            self.feedbackLabel.text = "There are no settings to be set yet."
//            return
//        }
//        
//        setSettingsButton.isEnabled = false
//        
//        let _ = CoreManager.shared().camera.setSetting(setting: Setting(id: settingID, option: Option(id: optionID)))
//            .do(onError: { error in
//                self.feedbackLabel.text = "Set settings failed: \(error.localizedDescription).\nSettingID: \(settingID), optionID: \(optionID)"
//                self.setSettingsButton.isEnabled = true
//            }, onCompleted: {
//                self.feedbackLabel.text = "Set settings succeeded\nSettingID: \(settingID), optionID: \(optionID)"
//                self.setSettingsButton.isEnabled = true
//            })
//            .subscribe()
//            .disposed(by: disposeBag)
    }
    
    // Anotacao
    func openSettings() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "SettingsNavigationController") as! UINavigationController
        navigationController.modalPresentationStyle = .formSheet
        
        (navigationController.viewControllers.first as? CameraSettingsViewController)?.currentSettings = currentCameraSettings
        (navigationController.viewControllers.first as? CameraSettingsViewController)?.possibleSettingOptions = possibleCameraSettingOptions
        
        self.present(navigationController, animated: true)
    }

    
    // MARK: - Subscribe to observers.
    
    func startObserving() {
        // Listen to camera mode
        let _ = CoreManager.shared().camera.cameraModeObservable
            .subscribe(
                onNext:{ mode in
                    NSLog("Changed mode to: \(mode)")
                }, onError: { error in
                    NSLog("Error cameraModeSubscription: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        // Listen to capture info
        let _ = CoreManager.shared().camera.captureInfoObservable
            .subscribe(onNext: { info in
                    NSLog("Capture info: \(info)")
                }, onError: { error in
                    NSLog("Error captureInfoSubscription: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        // Listen to camera status
        let _ = CoreManager.shared().camera.cameraStatusObservable
            .subscribe(onNext: { [weak self] status in
                let string = " Video On: \(status.videoOn) | Photo Interval On: \(status.photoIntervalOn) | Used Storage: \(status.usedStorageMib) | Available Storage: \(status.availableStorageMib) | Total Storage \(status.totalStorageMib) | Storage Status: \(status.storageStatus.hashValue) "
                self?.cameraStatusLabel.text = string
                }, onError: { error in
                    NSLog("Error cameraStatusSubscription: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)

        // Listen to current settings
        let _ = CoreManager.shared().camera.currentSettingsObservable
            .subscribe(onNext: { currentSettings in
                    self.currentCameraSettings.value = currentSettings
                    NSLog("Current settings: \(currentSettings)")
                }, onError: { error in
                    NSLog("Error currentSettingsSubscription: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        // Listen to possible settings
        let _ = CoreManager.shared().camera.possibleSettingOptionsObservable
            .subscribe(onNext: { [weak self] possibleSettingOptions in
                
                    self?.possibleCameraSettingOptions.value = possibleSettingOptions
                
                    // Save first possible setting to be set in setSettings (just for example purposes)
                    self?.globalSetting.settingID = possibleSettingOptions.first?.settingId
                    self?.globalSetting.optionID = possibleSettingOptions.first?.options.first?.id
                
                    var possibleSettingOptionsString = ""
                
                    possibleSettingOptions.forEach { (setting) in
                        let optionsArray = setting.options.map { $0.id }
                        possibleSettingOptionsString += "\nSetting: \(setting.settingId), Options: \(optionsArray)"
                    }
                
                    NSLog("Possible settings: \(possibleSettingOptionsString)")
                }, onError: { error in
                    NSLog("Error possibleSettingOptionsSubscription: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}