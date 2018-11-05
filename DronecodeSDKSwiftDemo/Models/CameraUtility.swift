//
//  CameraUtility.swift
//  YuneecMFiExample
//
//  Created by Joe Zhu on 2018/10/26.
//  Copyright © 2018年 Marjory Silvestre. All rights reserved.
//

import Foundation
import RxSwift
import Dronecode_SDK_Swift

class CameraUtility {
    var currentCameraMode:CameraMode = CameraMode.unknown
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

    func switchToMode(mode: CameraMode) {
        let semaphore = DispatchSemaphore(value: 0)

        if (self.currentCameraMode == mode) {
            return
        } else {
            if ((mode == CameraMode.photo)
                && (self.currentCameraMode == CameraMode.video)
                && (self.currentVideoState == "Recording")) {
                CoreManager.shared().camera.stopVideo()
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

            CoreManager.shared().camera.setMode(mode: mode)
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
                self.switchToMode(mode: CameraMode.photo)

                if (self.currentCameraMode != CameraMode.photo) {
                    return
                }

                CoreManager.shared().camera.takePhoto()
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
                self.switchToMode(mode: CameraMode.video)

                if (self.currentCameraMode != CameraMode.video) {
                    return
                }

                if (self.currentVideoState != "Recording") {
                    CoreManager.shared().camera.startVideo()
                        .do(onError: { error in
                            NSLog("startRecordingVideo failed:%@",error.localizedDescription);
                        }, onCompleted: {
                            self.currentVideoState = "Recording"
                        })
                        .subscribe()
                        .disposed(by: self.disposeBag)
                } else {
                    CoreManager.shared().camera.stopVideo()
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
            self.currentCameraMode = CameraMode.photo
            self.getModeDone = 1
        } else if (mode == "Video") {
            self.currentCameraMode = CameraMode.video
            self.getModeDone = 1
        }
    }

    func setVideoState(state: String) {
        self.currentVideoState = state
    }
}
