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
    
    
    var value = 0 // Anotacao
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mfiStatus.text = "View officially loaded"
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleConnectionStateNotification(notification:)),
//            name: Notification.Name("MFiConnectionStateNotification"),
//            object: nil)
        connection() // Anotacao
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
        var dispose = DisposeBag()
        
       let calibration = CoreManager.shared().drone.calibration.calibrateAccelerometer
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
        }.share().subscribe()
        
//        calibration.share().subscribe().disposed(by: dispose)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            print("+DC+ Entrou")
            calibration.dispose()
        }
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
    
    // Anotacao
    func connection() {
//        NotificationCenter.default.rx.notification(Notification.Name("MFiConnectionStateNotification"))
//            .map { $0 as Any }
//            .monitorMFiConnection(checkTime: 5.0, scheduler: MainScheduler.instance)
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { [weak self] isConnected in
//                print("Anotacao: Is Connected: \(isConnected)")
//                self?.calibrationLabel.text = "\(isConnected)"
//            }, onError: { (error) in
//                print("Error subscribing to MFi Connection: \(error.localizedDescription)")
//            })
//            .disposed(by: disposeBag)
        
        
        
        NotificationCenter.default.rx.notification(Notification.Name("MFiConnectionStateNotification"))
            .throttle(2.0, scheduler: MainScheduler.instance)
            .map ({ (notification) -> Bool in
                
                guard let numMessagesReceived = notification.userInfo?["NumMessagesReceived"] as? Int,
                    let connectionState = notification.userInfo?["MFiConnectionState"] as? Int else
                {
                    return false
                }
                print(notification)
//                print("Anotacao: Num of Messages Received: \(numMessagesReceived)")
                
                if connectionState == 1 {
                    if self.value == numMessagesReceived {
                        return false
                    } else {
                        self.value = numMessagesReceived
                        return true
                    }
                }
                
                return false
            })
            .distinctUntilChanged() // Make sure this doesn't break anything.
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isConnected in
                print("Anotacao: Is Connected: \(isConnected)")
                self?.calibrationLabel.text = "\(isConnected)"
                }, onError: { (error) in
                    print("Error subscribing to MFi Connection: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

}



//extension RxSwift.ObservableType where E == Any {
//    func monitorMFiConnection(checkTime: RxTimeInterval, scheduler: SchedulerType) -> Observable<Bool> {
//        return map { notification in
//
//            guard let notification = notification as? Notification,
//                let numMessagesReceived = notification.userInfo?["NumMessagesReceived"] as? Int,
//                let connectionState = notification.userInfo?["MFiConnectionState"] as? Int else
//            {
//                return false
//            }
//
//            print("Anotacao: Num of Messages Received: \(numMessagesReceived)")
//
//            if connectionState == 1 {
//                if value == numMessagesReceived {
//                    return false
//                } else {
//                    value = numMessagesReceived
//                    return true
//                }
//            }
//
//            return false // connectionState == 1
//            }
//            .timeout(checkTime, scheduler: scheduler)
//            .catchErrorJustReturn(false)
//    }
//}
