//
//  CameraUtility.swift
//  YuneecMFiExample
//
//  Created by Joe Zhu on 2018/10/26.
//  Copyright © 2018年 Marjory Silvestre. All rights reserved.
//

import Foundation
import RxSwift
import MAVSDK_Swift

class CameraUtility {
    var currentCameraMode:Camera.CameraMode = Camera.CameraMode.unknown
    var currentVideoState:String = "Unknown"
    var getModeDone:Int = 0

    private let disposeBag = DisposeBag()

    private static var mInstance:CameraUtility?

    static func sharedInstance() -> CameraUtility {
        if mInstance == nil {
            mInstance = CameraUtility()
        }
        return mInstance!
    }

    init() {

    }

    func switchToMode(mode: Camera.CameraMode) {
        let semaphore = DispatchSemaphore(value: 0)

        if (self.currentCameraMode == mode) {
            return
        } else {
            if ((mode == Camera.CameraMode.photo)
                && (self.currentCameraMode == Camera.CameraMode.video)
                && (self.currentVideoState == "Recording")) {
                CoreManager.shared().drone.camera.stopVideo()
                    .do(onError: { error in
                        NSLog("stopRecordingVideo failed:%@",error.localizedDescription);
                        semaphore.signal()
                    }, onCompleted: {
                        self.currentVideoState = "Ready"
                        semaphore.signal()
                    })
                    .subscribe()
                    .disposed(by: disposeBag)

                semaphore.wait()
            }

            CoreManager.shared().drone.camera.setMode(cameraMode: mode)
                .do(onError: { error in
                    NSLog("set mode failed:%@",error.localizedDescription);
                    semaphore.signal()
                }, onCompleted: {
                    self.currentCameraMode = mode
                    semaphore.signal()
                })
                .subscribe()
                .disposed(by: disposeBag)

            semaphore.wait()
        }
    }

    func handleRcButton(key: String) {
        let queue = DispatchQueue(label: "rcButton")

        if (key != "Camera Button") && (key != "Video Button") {
            return
        }

        if (key == "Camera Button") {
            queue.async {
                self.switchToMode(mode: Camera.CameraMode.photo)

                if (self.currentCameraMode != Camera.CameraMode.photo) {
                    return
                }

                CoreManager.shared().drone.camera.takePhoto()
                    .do(onError: { error in
                        NSLog("takePhoto failed:%@",error.localizedDescription);
                    }, onCompleted: {
                        NSLog("takePhoto successfully");
                    })
                    .subscribe()
                    .disposed(by: self.disposeBag)
            }
        } else {
            queue.async {
                self.switchToMode(mode: Camera.CameraMode.video)

                if (self.currentCameraMode != Camera.CameraMode.video) {
                    return
                }

                if (self.currentVideoState != "Recording") {
                    CoreManager.shared().drone.camera.startVideo()
                        .do(onError: { error in
                            NSLog("startRecordingVideo failed:%@",error.localizedDescription);
                        }, onCompleted: {
                            self.currentVideoState = "Recording"
                        })
                        .subscribe()
                        .disposed(by: self.disposeBag)
                } else {
                    CoreManager.shared().drone.camera.stopVideo()
                        .do(onError: { error in
                            NSLog("stopRecordingVideo failed:%@",error.localizedDescription);
                        }, onCompleted: {
                            self.currentVideoState = "Ready"
                        })
                        .subscribe()
                        .disposed(by: self.disposeBag)
                }
            }
        }
    }

    func setCameraMode(mode: String) {
        if (mode == "Photo") {
            self.currentCameraMode = Camera.CameraMode.photo
            self.getModeDone = 1
        } else if (mode == "Video") {
            self.currentCameraMode = Camera.CameraMode.video
            self.getModeDone = 1
        }
    }

    func setVideoState(state: String) {
        self.currentVideoState = state
    }
}
