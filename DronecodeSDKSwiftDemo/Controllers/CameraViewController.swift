//
//  CameraViewController.swift
//  YuneecMFiExample
//
//  Created by Douglas on 8/7/18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import UIKit
import RxSwift
import MAVSDK_Swift
import Eureka
import RxCocoa

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
    @IBOutlet weak var cameraModeLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var videoFeedViewController: UIViewController?
    
    private let disposeBag = DisposeBag()
    
    var currentCameraSettings = BehaviorRelay<[Camera.Setting]>(value: [])
    var possibleCameraSettingOptions = BehaviorRelay<[Camera.SettingOptions]>(value: [])

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
        
        embedContainerView()
    }
    
    func embedContainerView() {
        videoFeedViewController = storyboard?.instantiateViewController(withIdentifier: "VideoFeedViewController")
        guard let videoFeedViewController = videoFeedViewController else {
            return
        }
        
        addChildViewController(videoFeedViewController)
        videoFeedViewController.didMove(toParentViewController: self)
        
        if let videoFeedSubview = videoFeedViewController.view {
            containerView.addSubview(videoFeedSubview)

            videoFeedSubview.translatesAutoresizingMaskIntoConstraints = false
            videoFeedSubview.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            videoFeedSubview.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            videoFeedSubview.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

            videoFeedSubview.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        }
    }
    
    @IBAction func setPhotoMode(_ sender: UIButton) {
        setPhotoModeButton.isEnabled = false
        
        CoreManager.shared().drone.camera.setMode(cameraMode: .photo)
            .do(onError: { error in
                self.feedbackLabel.text = "Set photo mode failed: \(error.localizedDescription)"
                self.setPhotoModeButton.isEnabled = true
            }, onCompleted: {
                self.feedbackLabel.text = "Set photo mode succeeded"
                self.setPhotoModeButton.isEnabled = true
                CameraUtility.sharedInstance().setCameraMode(mode: "Photo")
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func takePhotoPressed(_ sender: Any) {
        takePhotoButton.isEnabled = false
        
        CoreManager.shared().drone.camera.takePhoto()
            .do(onError: { error in
                self.feedbackLabel.text = "Take photo failed: \(error.localizedDescription)"
                self.takePhotoButton.isEnabled = true
            }, onCompleted: {
                self.feedbackLabel.text = "Take photo succeeded"
                self.takePhotoButton.isEnabled = true
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func startPhotoInterval(_ sender: UIButton) {
        startPhotoIntervalButton.isEnabled = false
        
        CoreManager.shared().drone.camera.startPhotoInterval(intervalS: 5)
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

        CoreManager.shared().drone.camera.stopPhotoInterval()
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
        
        CoreManager.shared().drone.camera.setMode(cameraMode: .video)
            .do(onError: { error in
                self.feedbackLabel.text = "Set video mode failed: \(error.localizedDescription)"
                self.setVideoModeButton.isEnabled = true
            }, onCompleted: {
                self.feedbackLabel.text = "Set video mode succeeded"
                self.setVideoModeButton.isEnabled = true
                CameraUtility.sharedInstance().setCameraMode(mode: "Video")
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func startVideo(_ sender: UIButton) {
        startVideoButton.isEnabled = false
        
        CoreManager.shared().drone.camera.startVideo()
            .do(onError: { error in
                self.feedbackLabel.text = "Start video failed: \(error.localizedDescription)"
                self.startVideoButton.isEnabled = true
            }, onCompleted: {
                self.feedbackLabel.text = "Start video succeeded"
                self.startVideoButton.isEnabled = true
                CameraUtility.sharedInstance().setVideoState(state: "Recording")
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func stopVideo(_ sender: UIButton) {
        stopVideoButton.isEnabled = false
        
        CoreManager.shared().drone.camera.stopVideo()
            .do(onError: { error in
                self.feedbackLabel.text = "Stop video failed: \(error.localizedDescription)"
                self.stopVideoButton.isEnabled = true
            }, onCompleted: {
                self.feedbackLabel.text = "Stop video succeeded"
                self.stopVideoButton.isEnabled = true
                CameraUtility.sharedInstance().setVideoState(state: "Ready")
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func setSettings(_ sender: UIButton) {
        openSettings()
    }
    
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
        CoreManager.shared().drone.camera.mode
            .subscribe(
                onNext:{ [weak self] mode in
                    NSLog("Changed mode to: \(mode)")
                    
                    switch mode {
                    case .photo:
                       self?.cameraModeLabel.text = "Photo"
                       self?.cameraModeLabel.textColor = .white
                    case .video:
                        self?.cameraModeLabel.text = "Video"
                        self?.cameraModeLabel.textColor = UIColor.init(red: 145/255, green: 44/255, blue: 0/255, alpha: 1)
                    default:
                        self?.cameraModeLabel.text = "Unknown"
                        self?.cameraModeLabel.textColor = .lightGray
                    }

                }, onError: { error in
                    NSLog("Error cameraModeSubscription: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        // Listen to capture info
        CoreManager.shared().drone.camera.captureInfo
            .subscribe(onNext: { info in
                    NSLog("Capture info: \(info)")
                }, onError: { error in
                    NSLog("Error captureInfoSubscription: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        // Listen to camera status
        CoreManager.shared().drone.camera.cameraStatus
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { status in
                let string = "Video On: \(status.videoOn) | Photo Interval On: \(status.photoIntervalOn) | Used Storage: \(status.usedStorageMib) | Available Storage: \(status.availableStorageMib) | Total Storage \(status.totalStorageMib) | Storage Status: \(status.storageStatus)"
                    self.cameraStatusLabel.text = string
               }, onError: { error in
                    NSLog("Error cameraStatusSubscription: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)

        // Listen to current settings
        CoreManager.shared().drone.camera.currentSettings
            .subscribe(onNext: { currentSettings in
                    self.currentCameraSettings.accept(currentSettings)
                    NSLog("Current settings: \(currentSettings)")
                }, onError: { error in
                    NSLog("Error currentSettingsSubscription: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        // Listen to possible settings
        CoreManager.shared().drone.camera.possibleSettingOptions
            .subscribe(onNext: { possibleSettingOptions in
                    self.possibleCameraSettingOptions.accept(possibleSettingOptions)
                    NSLog("Possible settings: \(possibleSettingOptions)")
                }, onError: { error in
                    NSLog("Error possibleSettingOptionsSubscription: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
}
