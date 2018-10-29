//
//  CameraUtility.swift
//  YuneecMFiExample
//
//  Created by Joe Zhu on 2018/10/26.
//  Copyright © 2018年 Marjory Silvestre. All rights reserved.
//

import Foundation


class CameraUtility {
    var currentCameraMode:YuneecCameraMode = YuneecCameraMode.unknown
    var currentVideoState:String = "Unknown"
    var getModeDone:Int = 0

    private static var mInstance:CameraUtility?

    static func sharedInstance() -> CameraUtility {
        if mInstance == nil {
            mInstance = CameraUtility()
        }
        return mInstance!
    }

    init() {
        MFiAdapter.MFiCameraAdapter.sharedInstance().getCameraMode { (error, mode) in
            if let error = error {
                NSLog("getCameraMode failed:%@",error.localizedDescription);
            } else {
                self.currentCameraMode = mode
                self.getModeDone = 1
            }
        }
    }

    func switchToMode(mode: YuneecCameraMode) {
        let semaphore = DispatchSemaphore(value: 0)

        if (self.getModeDone == 0) {
            MFiAdapter.MFiCameraAdapter.sharedInstance().getCameraMode { (error, mode) in
                if let error = error {
                    NSLog("getCameraMode failed:%@",error.localizedDescription);
                } else {
                    self.currentCameraMode = mode
                    self.getModeDone = 1
                }
                semaphore.signal()
            }
        } else {
            semaphore.signal()
        }

        semaphore.wait()

        if (self.getModeDone == 0) {
            return
        }

        if (self.currentCameraMode == mode) {
            return
        } else {
            if ((mode == YuneecCameraMode.photo)
                && (self.currentCameraMode == YuneecCameraMode.video)
                && (self.currentVideoState == "Recording")) {
                MFiAdapter.MFiCameraAdapter.sharedInstance().stopRecordingVideo { (error) in
                    if let error = error {
                        NSLog("stopRecordingVideo failed:%@",error.localizedDescription);
                    } else {
                        self.currentVideoState = "Ready"
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            }

            MFiAdapter.MFiCameraAdapter.sharedInstance().setCameraMode(mode, block: { (error) in
                if let error = error {
                    NSLog("set Photo mode failed:%@",error.localizedDescription);
                } else {
                    self.currentCameraMode = mode
                }
                semaphore.signal()
            })
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
                self.switchToMode(mode: YuneecCameraMode.photo)

                if (self.currentCameraMode != YuneecCameraMode.photo) {
                    return
                }

                MFiAdapter.MFiCameraAdapter.sharedInstance().takePhoto { (error) in
                    if let error = error {
                        NSLog("takePhoto failed:%@",error.localizedDescription);
                    } else {
                        NSLog("takePhoto successfully");
                    }
                }
            }
        } else {
            queue.async {
                self.switchToMode(mode: YuneecCameraMode.video)

                if (self.currentCameraMode != YuneecCameraMode.video) {
                    return
                }

                if (self.currentVideoState != "Recording") {
                    MFiAdapter.MFiCameraAdapter.sharedInstance().startRecordingVideo { (error) in
                        if let error = error {
                            NSLog("startRecordingVideo failed:%@",error.localizedDescription);
                        } else {
                            self.currentVideoState = "Recording"
                        }
                    }
                } else {
                    MFiAdapter.MFiCameraAdapter.sharedInstance().stopRecordingVideo { (error) in
                        if let error = error {
                            NSLog("stopRecordingVideo failed:%@",error.localizedDescription);
                        } else {
                            self.currentVideoState = "Ready"
                        }
                    }
                }
            }
        }
    }

    func setCameraMode(mode: String) {
        if (mode == "Photo") {
            self.currentCameraMode = YuneecCameraMode.photo
            self.getModeDone = 1
        } else if (mode == "Video") {
            self.currentCameraMode = YuneecCameraMode.video
            self.getModeDone = 1
        }
    }

    func setVideoState(state: String) {
        self.currentVideoState = state
    }
}
