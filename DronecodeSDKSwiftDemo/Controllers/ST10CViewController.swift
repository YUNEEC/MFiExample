//
//  ST10CViewController.swift
//  DronecodeSDKSwiftDemo
//
//  Created by Julian Oes on 27.04.18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import Foundation
import UIKit
import MFiAdapter
import RxSwift
import RxCocoa

class ST10CViewController: UIViewController {
    
    @IBOutlet weak var mfiStatus: UITextView!
    
    @IBOutlet weak var calibrationLabel: UILabel!
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        mfiStatus.text = "View officially loaded"
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleConnectionStateNotification(notification:)),
            name: Notification.Name("MFiConnectionStateNotification"),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        calibrateAccelerometer()
//        calibrateGyro()
//        calibrateCompass()
    }
    
    @objc func handleConnectionStateNotification(notification: NSNotification) {
        mfiStatus.text = String(describing:notification.userInfo)
    }
    
    func calibrateAccelerometer() {
       let calibration = CoreManager.shared().drone.calibration.calibrateAccelerometer
        .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
        .observeOn(MainScheduler.instance)
            .do(onNext: { (progressData) in
                let text = "+DC+ Progress: \(progressData.hasProgress), Progress: \(progressData.progress), Has Status Text: \(progressData.hasStatusText), Status Text: \(progressData.statusText)"
                print(text)
                self.calibrationLabel.text = text
            }, onError: { (error) in
                print("+DC+ Error \(error)")
            }, onCompleted: {
                print("+DC+ Completed")
            }, onSubscribe: {
                print("+DC+ Subscribe")
            }, onSubscribed: {
                print("+DC+ Subscribed")
            }) {
               print("+DC+ Disposed")
        }
        .share()
        .subscribe()
        
        calibration.disposed(by: disposeBag)
    }
    
    func calibrateCompass() {
        let calibration = CoreManager.shared().drone.calibration.calibrateMagnetometer
            .do(onNext: { (progressData) in
                let text = "+DC+ Progress: \(progressData.hasProgress), Progress: \(progressData.progress), Has Status Text: \(progressData.hasStatusText), Status Text: \(progressData.statusText)"
                print(text)
                self.calibrationLabel.text = text
            }, onError: { (error) in
                print("+DC+ Error \(error)")
            }, onCompleted: {
                print("+DC+ Completed")
            }, onSubscribe: {
                print("+DC+ Subscribe")
            }, onSubscribed: {
                print("+DC+ Subscribed")
            }) {
                print("+DC+ Disposed")
        }

        calibration.share().subscribe().disposed(by: disposeBag)
    }
    
    func calibrateGyro() {
        CoreManager.shared().drone.calibration.calibrateGyro
            .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (progressData) in
                let text = "Has Progress: \(progressData.hasProgress), Progress: \(progressData.progress), Has Status Text: \(progressData.hasStatusText), Status Text: \(progressData.statusText)"
                print(text)
                self.calibrationLabel.text = text
            }, onError: { (error) in
                self.calibrationLabel.text = "Error \(error)"
            }, onCompleted: {
                self.calibrationLabel.text = "Completed"
            }, onDisposed: {
                self.calibrationLabel.text = "Disposed"
            })
        .disposed(by: disposeBag)
    }
}
