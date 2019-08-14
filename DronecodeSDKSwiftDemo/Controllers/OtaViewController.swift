//
//  OtaViewController.swift
//  YuneecMFiExample
//
//  Created by Joe Zhu on 2018/9/25.
//  Copyright © 2018年 Marjory Silvestre. All rights reserved.
//

import Foundation
import UIKit
import MFiAdapter
import MAVSDK_Swift
import RxSwift


class OtaViewController: UIViewController {

    let autopilotFileName:String = "autopilot.yuneec"
    let cameraFileName:String = "firmware.bin"
    let gimbalFileName:String = "gimbal.yuneec"
    let rcFileName:String = "update.lzo"

    var autopilotVersion:String = ""
    var cameraVersion:String = ""
    var gimbalVersion:String = ""
    var rcVersion:String = ""
    var autopilotHash:String = ""
    var cameraHash:String = ""
    var gimbalHash:String = ""
    var rcHash:String = ""
    var currentAutopilotVersion:String = ""
    var currentCameraVersion:String = ""
    var currentGimbalVersion:String = ""
    var currentRcVersion:String = ""
    
    private let disposeBag = DisposeBag()

    @IBOutlet weak var refresh: UIButton!
    @IBOutlet weak var download: UIButton!
    @IBOutlet weak var upload: UIButton!
    @IBOutlet weak var autopilotInfo: UILabel!
    @IBOutlet weak var cameraInfo: UILabel!
    @IBOutlet weak var gimbalInfo: UILabel!
    @IBOutlet weak var rcInfo: UILabel!
    @IBOutlet weak var autopilotWait: UIActivityIndicatorView!
    @IBOutlet weak var cameraWait: UIActivityIndicatorView!
    @IBOutlet weak var gimbalWait: UIActivityIndicatorView!
    @IBOutlet weak var rcWait: UIActivityIndicatorView!
    @IBOutlet weak var segment: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.autopilotInfo.text = "Autopilot:"
        self.cameraInfo.text = "Camera:"
        self.gimbalInfo.text = "Gimbal:"
        self.rcInfo.text = "RC:"

        // Setup buttons
        refresh.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        download.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        upload.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS

        let fileManager = FileManager.default
        let path:String = self.getLocalPath()
        let exist = fileManager.fileExists(atPath: path)
        if !exist {
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true,
                                             attributes: nil)
        }
    }

    func getLocalPath() -> String {
        return NSTemporaryDirectory() + "ota"
    }

    func getLocalOtaFilePath(fileName:String) -> String {
        return self.getLocalPath() + "/" + fileName
    }

    func isOtaFileExist(fileName:String) -> Bool {
        let fileManager = FileManager.default
        let filepath = self.getLocalOtaFilePath(fileName: fileName)

        return fileManager.fileExists(atPath: filepath)
    }

    @IBAction func refresh(_ sender: UIButton) {
        self.refresh.isEnabled = false
        let semaphore = DispatchSemaphore(value: 0)
        let queue = DispatchQueue(label: "refresh")

        if (segment.selectedSegmentIndex == 0) {
            queue.async {
                DispatchQueue.main.async {
                    self.autopilotWait.startAnimating()
                }
                
                MFiAdapter.MFiOtaAdapter.sharedInstance().getLatestVersion(.autopilot, block: { (version) in
                    DispatchQueue.main.async {
                        let myRoutine = CoreManager.shared().drone.info.getVersion()
                        myRoutine.subscribe{ event in
                            switch event {
                            case .success(let version):
                                self.currentAutopilotVersion = "v\(version.flightSwMajor).\(version.flightSwMinor).\(version.flightSwPatch)-\(version.flightSwVendorMajor).\(version.flightSwVendorMinor).\(version.flightSwVendorPatch)"
                                break
                            case .error(let error):
                                self.currentAutopilotVersion = "Unknown"
                                print("failed getting autopilot version: ", error)
                                break;
                            }
                            semaphore.signal()
                        }.disposed(by: self.disposeBag)
                    }
                })
                semaphore.wait()
                
                MFiAdapter.MFiOtaAdapter.sharedInstance().getLatestVersion(.autopilot, block: { (version) in
                    DispatchQueue.main.async {
                        self.autopilotVersion = version!
                        self.autopilotInfo.text = self.autopilotFileName + "(" + self.currentAutopilotVersion + ")" + "(new:" + self.autopilotVersion + ")"
                        self.refresh.isEnabled = true
                        semaphore.signal()
                    }
                })
                semaphore.wait()

                MFiAdapter.MFiOtaAdapter.sharedInstance().getLatestHash(.autopilot, block: { (hash) in
                    DispatchQueue.main.async {
                        self.autopilotHash = hash!
                        self.autopilotWait.stopAnimating()
                    }
                })
            }
        }

        if (segment.selectedSegmentIndex == 1) {
            queue.async {
                DispatchQueue.main.async {
                    self.cameraWait.startAnimating()
                }

                MFiAdapter.MFiCameraAdapter.sharedInstance().getFirmwareVersion({ (version) in
                    self.currentCameraVersion = version!
                    semaphore.signal()
                })

                semaphore.wait()

                MFiAdapter.MFiOtaAdapter.sharedInstance().getLatestVersion(.cameraE90A, block: { (version) in
                    DispatchQueue.main.async {
                        self.cameraVersion = version!
                        self.cameraInfo.text = self.cameraFileName + "(" + self.currentCameraVersion + ")" + "(new:" + self.cameraVersion + ")"
                        self.refresh.isEnabled = true
                        semaphore.signal()
                    }
                })

                semaphore.wait()

                MFiAdapter.MFiOtaAdapter.sharedInstance().getLatestHash(.cameraE90A, block: { (hash) in
                    DispatchQueue.main.async {
                        self.cameraHash = hash!
                        self.cameraWait.stopAnimating()
                    }
                })
            }
        }

        if (segment.selectedSegmentIndex == 2) {
            queue.async {
                DispatchQueue.main.async {
                    self.gimbalWait.startAnimating()
                }
                
                MFiAdapter.MFiCameraAdapter.sharedInstance().getGimbalFirmwareVersion({ (version ) in
                    self.currentGimbalVersion = version!
                    semaphore.signal()
                })

                semaphore.wait()

                MFiAdapter.MFiOtaAdapter.sharedInstance().getLatestVersion(.gimbalE90, block: { (version) in
                    DispatchQueue.main.async {
                        self.gimbalVersion = version!
                        self.gimbalInfo.text = self.gimbalFileName + "(" + self.currentGimbalVersion + ")" + "(new:" + self.gimbalVersion + ")"
                        self.refresh.isEnabled = true
                        semaphore.signal()
                    }
                })

                semaphore.wait()

                MFiAdapter.MFiOtaAdapter.sharedInstance().getLatestHash(.gimbalE90, block: { (hash) in
                    DispatchQueue.main.async {
                        self.gimbalHash = hash!
                        self.gimbalWait.stopAnimating()
                    }
                })
            }
        }

        if (segment.selectedSegmentIndex == 3) {
            queue.async {
                DispatchQueue.main.async {
                    self.rcWait.startAnimating()
                }
            MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().getFirmwareVersionInfo({ (version ) in
                    self.currentRcVersion = version!
                    semaphore.signal()
                })

                semaphore.wait()

                MFiAdapter.MFiOtaAdapter.sharedInstance().getLatestVersion(.rcST10C, block: { (version) in
                    DispatchQueue.main.async {
                        self.rcVersion = version!
                        self.rcInfo.text = self.rcFileName + "(" + self.currentRcVersion + ")" + "(new:" + self.rcVersion + ")"
                        self.refresh.isEnabled = true
                        semaphore.signal()
                    }
                })

                semaphore.wait()

                MFiAdapter.MFiOtaAdapter.sharedInstance().getLatestHash(.rcST10C, block: { (hash) in
                    DispatchQueue.main.async {
                        self.rcHash = hash!
                        self.rcWait.stopAnimating()
                    }
                })
            }
        }

        self.refresh.isEnabled = true
    }

    @IBAction func download(_ sender: UIButton) {
        self.download.isEnabled = false
        let autopilotFilePath:String = getLocalOtaFilePath(fileName: self.autopilotFileName)
        let cameraFilePath:String = getLocalOtaFilePath(fileName: self.cameraFileName)
        let gimbalFilePath:String = getLocalOtaFilePath(fileName: self.gimbalFileName)
        let rcFilePath:String = getLocalOtaFilePath(fileName: self.rcFileName)

        if (segment.selectedSegmentIndex == 0) {
            self.autopilotWait.startAnimating()
            MFiAdapter.MFiOtaAdapter.sharedInstance().downloadOtaPackage(.autopilot, filePath: autopilotFilePath, progressBlock: {(progress) in
                DispatchQueue.main.async {
                    self.autopilotInfo.text = self.autopilotFileName + "(" + self.autopilotVersion + ")" + ":" + String(Int(progress * 100)) + "%"
                }
            }, completionBlock: { (error) in
                DispatchQueue.main.async {
                    if (error == nil) {
                        let hash:String = MFiAdapter.MFiOtaAdapter.sharedInstance().sha256(ofPath: autopilotFilePath)
                        if (hash == self.autopilotHash) {
                            self.autopilotInfo.text = self.autopilotFileName + "(" + self.currentAutopilotVersion + ")" + "(new:" + self.autopilotVersion + ")" + ":" + "Download successfully and HASH match!"
                        } else {
                            self.autopilotInfo.text = self.autopilotFileName + "(" + self.currentAutopilotVersion + ")" + "(new:" + self.autopilotVersion + ")" + ":" + "Download successful, but HASH mismatch!!"
                        }
                    } else {
                        self.autopilotInfo.text = self.autopilotFileName + "(" + self.currentAutopilotVersion + ")" + "(new:" + self.autopilotVersion + ")" + ":" + "error:" + error!.localizedDescription
                    }
                    self.autopilotWait.stopAnimating()
                }
            })
        }

        if (segment.selectedSegmentIndex == 1) {
            self.cameraWait.startAnimating()
            MFiAdapter.MFiOtaAdapter.sharedInstance().downloadOtaPackage(.cameraE90A, filePath: cameraFilePath, progressBlock: {(progress) in
                DispatchQueue.main.async {
                    self.cameraInfo.text = self.cameraFileName + "(" + self.currentCameraVersion + ")" + "(new:" + self.cameraVersion + ")" + ":" + String(Int(progress * 100)) + "%"
                }
            }, completionBlock: { (error) in
                DispatchQueue.main.async {
                    if (error == nil) {
                        let hash:String = MFiAdapter.MFiOtaAdapter.sharedInstance().sha256(ofPath: cameraFilePath)
                        if (hash == self.cameraHash) {
                            self.cameraInfo.text = self.cameraFileName + "(" + self.currentCameraVersion + ")" + "(new:" + self.cameraVersion + ")" + ":" + "Download successfully and HASH match!"
                        } else {
                            self.cameraInfo.text = self.cameraFileName + "(" + self.currentCameraVersion + ")" + "(new:" + self.cameraVersion + ")" + ":" + "Download successful, but HASH mismatch!!"
                        }
                    } else {
                        self.cameraInfo.text = self.cameraFileName + "(" + self.currentCameraVersion + ")" + "(new:" + self.cameraVersion + ")" + ":" + "error:" + error!.localizedDescription
                    }
                    self.cameraWait.stopAnimating()
                }
            })
        }

        if (segment.selectedSegmentIndex == 2) {
            self.gimbalWait.startAnimating()
            MFiAdapter.MFiOtaAdapter.sharedInstance().downloadOtaPackage(.gimbalE90, filePath: gimbalFilePath, progressBlock: {(progress) in
                DispatchQueue.main.async {
                    self.gimbalInfo.text = self.gimbalFileName + "(" + self.gimbalVersion + ")" + ":" + String(Int(progress * 100)) + "%"
                }
            }, completionBlock: { (error) in
                DispatchQueue.main.async {
                    if (error == nil) {
                        let hash:String = MFiAdapter.MFiOtaAdapter.sharedInstance().sha256(ofPath: gimbalFilePath)
                        if (hash == self.gimbalHash) {
                            self.gimbalInfo.text = self.gimbalFileName + "(" + self.currentGimbalVersion + ")" + "(new:" + self.gimbalVersion + ")" + ":" + "Download successfully and HASH match!"
                        } else {
                            self.gimbalInfo.text = self.gimbalFileName + "(" + self.currentGimbalVersion + ")" + "(new:" + self.gimbalVersion + ")" + ":" + "Download successful, but HASH mismatch!!"
                        }
                    } else {
                        self.gimbalInfo.text = self.gimbalFileName + "(" + self.currentGimbalVersion + ")" + "(new:" + self.gimbalVersion + ")" + ":" + "error:" + error!.localizedDescription
                    }
                    self.gimbalWait.stopAnimating()
                }
            })
        }

        if (segment.selectedSegmentIndex == 3) {
            self.rcWait.startAnimating()
            MFiAdapter.MFiOtaAdapter.sharedInstance().downloadOtaPackage(.rcST10C, filePath: rcFilePath, progressBlock: {(progress) in
                DispatchQueue.main.async {
                    self.rcInfo.text = self.rcFileName + "(" + self.rcVersion + ")" + ":" + String(Int(progress * 100)) + "%"
                }
            }, completionBlock: { (error) in
                DispatchQueue.main.async {
                    if (error == nil) {
                        let hash:String = MFiAdapter.MFiOtaAdapter.sharedInstance().sha256(ofPath: rcFilePath)
                        if (hash == self.rcHash) {
                            self.rcInfo.text = self.rcFileName + "(" + self.currentRcVersion + ")" + "(new:" + self.rcVersion + ")" + ":" + "Download successfully and HASH match!"
                        } else {
                            self.rcInfo.text = self.rcFileName + "(" + self.currentRcVersion + ")" + "(new:" + self.rcVersion + ")" + ":" + "Download successful, but HASH mismatch!!"
                        }
                    } else {
                        self.rcInfo.text = self.rcFileName + "(" + self.currentRcVersion + ")" + "(new:" + self.rcVersion + ")" + ":" + "error:" + error!.localizedDescription
                    }
                    self.rcWait.stopAnimating()
                }
            })
        }
        self.download.isEnabled = true
    }

    @IBAction func uploadAutopilot(_ sender: UIButton) {
        self.upload.isEnabled = false

        let autopilotFilePath:String = getLocalOtaFilePath(fileName: self.autopilotFileName)
        let cameraFilePath:String = getLocalOtaFilePath(fileName: self.cameraFileName)
        let gimbalFilePath:String = getLocalOtaFilePath(fileName: self.gimbalFileName)
        let rcFilePath:String = getLocalOtaFilePath(fileName: self.rcFileName)

        if (segment.selectedSegmentIndex == 0) {
            self.autopilotWait.startAnimating()
            MFiAdapter.MFiOtaAdapter.sharedInstance().uploadOtaPackage(autopilotFilePath, progressBlock: {(progress                                                                                                                                                ) in
                DispatchQueue.main.async {
                    self.autopilotInfo.text = self.autopilotFileName + "(" + self.currentAutopilotVersion + ")" + "(new:" + self.autopilotVersion + ")" + ":" + String(Int(progress * 100)) + "%"
                }
            }, completionBlock: { (error) in
                DispatchQueue.main.async {
                    if (error == nil) {
                        self.autopilotInfo.text = self.autopilotFileName + "(" + self.currentAutopilotVersion + ")" + "(new:" + self.autopilotVersion + ")" + ":" + "upload successful"
                    } else {
                        self.autopilotInfo.text = self.autopilotFileName + "(" + self.currentAutopilotVersion + ")" + "(new:" + self.autopilotVersion + ")" + "error:" + error!.localizedDescription
                    }
                    self.autopilotWait.stopAnimating()
                }
            })
        }

        if (segment.selectedSegmentIndex == 1) {
            self.cameraWait.startAnimating()
            MFiAdapter.MFiOtaAdapter.sharedInstance().uploadOtaPackage(cameraFilePath, progressBlock: {(progress                                                                                                                                                ) in
                DispatchQueue.main.async {
                    self.cameraInfo.text = self.cameraFileName + "(" + self.currentCameraVersion + ")" + "(new:" + self.cameraVersion + ")" + ":" + String(Int(progress * 100)) + "%"
                }
            }, completionBlock: { (error) in
                DispatchQueue.main.async {
                    if (error == nil) {
                        self.cameraInfo.text = self.cameraFileName + "(" + self.currentCameraVersion + ")" + "(new:" + self.cameraVersion + ")" + ":" + "upload successful"
                    } else {
                        self.cameraInfo.text = self.cameraFileName + "(" + self.currentCameraVersion + ")" + "(new:" + self.cameraVersion + ")" + "error:" + error!.localizedDescription
                    }
                    self.cameraWait.stopAnimating()
                }
            })
        }

        if (segment.selectedSegmentIndex == 2) {
            self.gimbalWait.startAnimating()
            MFiAdapter.MFiOtaAdapter.sharedInstance().uploadOtaPackage(gimbalFilePath, progressBlock: {(progress                                                                                                                                                ) in
                DispatchQueue.main.async {
                    self.gimbalInfo.text = self.gimbalFileName + "(" + self.gimbalVersion + ")" + ":" + String(Int(progress * 100)) + "%"
                }
            }, completionBlock: { (error) in
                DispatchQueue.main.async {
                    if (error == nil) {
                        self.gimbalInfo.text = self.gimbalFileName + "(" + self.gimbalVersion + ")" + ":" + "upload successful"
                    } else {
                        self.gimbalInfo.text = self.gimbalFileName + "(" + self.gimbalVersion + ")" + "error:" + error!.localizedDescription
                    }
                    self.gimbalWait.stopAnimating()
                }
            })
        }
 
        if (segment.selectedSegmentIndex == 3) {
            self.rcWait.startAnimating()
            MFiAdapter.MFiOtaAdapter.sharedInstance().uploadRemoteControllerOtaPackage(rcFilePath, progressBlock: {(progress) in
                DispatchQueue.main.async {
                    self.rcInfo.text = self.rcFileName + "(" + self.rcVersion + ")" + ":" + String(Int(progress * 100)) + "%"
                }
            }, completionBlock: { (error) in
                DispatchQueue.main.async {
                    if (error == nil) {
                        self.rcInfo.text = self.rcFileName + "(" + self.currentRcVersion + ")" + "(new:" + self.rcVersion + ")" + ":" + "upload successful"
                    } else {
                        self.rcInfo.text = self.rcFileName + "(" + self.currentRcVersion + ")" + "(new:" + self.rcVersion + ")" + "error:" + error!.localizedDescription
                    }
                    self.rcWait.stopAnimating()
                }
            })
        }

        self.upload.isEnabled = true
    }
}
