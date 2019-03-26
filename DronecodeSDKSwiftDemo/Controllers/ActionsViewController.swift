//
//  ActionsViewController.swift
//  DronecodeSDKSwiftDemo
//
//  Created by Marjory Silvestre on 06.04.18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import UIKit
import Dronecode_SDK_Swift
import RxSwift

let UI_CORNER_RADIUS_BUTTONS = CGFloat(8.0)

class ActionsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var armButton: UIButton!
    @IBOutlet weak var takeoffButton: UIButton!
    @IBOutlet weak var landButton: UIButton!
    @IBOutlet weak var disarmButton: UIButton!
    @IBOutlet weak var killButton: UIButton!
    @IBOutlet weak var returnToLaunchButton: UIButton!
    @IBOutlet weak var transitionToFixedWingButton: UIButton!
    @IBOutlet weak var transitionToMulticopterButton: UIButton!
    @IBOutlet weak var getTakeoffAltitudeButton: UIButton!
    @IBOutlet weak var getMaxSpeedButton: UIButton!
    
    @IBOutlet weak var feedbackLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // init text for feedback and add round corner and border
        feedbackLabel.text = "Welcome"
        feedbackLabel.layer.cornerRadius   = UI_CORNER_RADIUS_BUTTONS
        feedbackLabel?.layer.masksToBounds = true
        feedbackLabel?.layer.borderColor = UIColor.lightGray.cgColor
        feedbackLabel?.layer.borderWidth = 1.0
        
        // set corners for buttons
        armButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        takeoffButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        landButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        disarmButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        killButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        returnToLaunchButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        transitionToFixedWingButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        transitionToMulticopterButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        getTakeoffAltitudeButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        getMaxSpeedButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func armPressed(_ sender: Any) {
        CoreManager.shared().drone.action.arm()
            .do(onError: { error in
                self.feedbackLabel.text = "Arming failed : \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Arming succeeded"
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func disarmPressed(_ sender: Any) {
        CoreManager.shared().drone.action.disarm()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onError: { error in
                self.feedbackLabel.text = "Disarming failed : \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Disarming succeeded"
                // Anotacao
                let threadName = getThreadName()
                print("[D] received on \(threadName)")
            })
            .observeOn(MainScheduler.instance)
            .subscribe({ (event) in
                let threadName = getThreadName()
                print("[S] received on \(threadName)")
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func takeoffPressed(_ sender: Any) {
        CoreManager.shared().drone.action.takeoff()
            .do(onError: { error in
                self.feedbackLabel.text = "Takeoff failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Takeoff succeeded"
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func landPressed(_ sender: Any) {
        CoreManager.shared().drone.action.land()
            .do(onError: { error in
                self.feedbackLabel.text = "Land failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Land succeeded"
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func killPressed(_ sender: Any) {
        CoreManager.shared().drone.action.kill()
            .do(onError: { error in
                self.feedbackLabel.text = "Kill failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Kill succeeded"
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func returnToLaunchPressed(_ sender: Any) {
        CoreManager.shared().drone.action.returnToLaunch()
            .do(onError: { error in
                self.feedbackLabel.text = "Return to launch failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "Return to launch succeeded"
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func transitionToFixedWingPressed(_ sender: Any) {
        CoreManager.shared().drone.action.transitionToFixedWing()
            .do(onError: { error in
                self.feedbackLabel.text = "transitionToFixedWing failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "transitionToFixedWing succeeded"
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func transitionToMulticopterPressed(_ sender: Any) {
        CoreManager.shared().drone.action.transitionToMulticopter()
            .do(onError: { error in
                self.feedbackLabel.text = "transitionToMulticopter failed: \(error.localizedDescription)"
            }, onCompleted: {
                self.feedbackLabel.text = "transitionToMulticopter succeeded"
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func getTakeoffAltitudePressed(_ sender: Any) {
        let myRoutine = CoreManager.shared().drone.action.getTakeoffAltitude()
        myRoutine.subscribe{ event in
            switch event {
            case .success(let altitude):
                self.feedbackLabel.text = "Takeoff altitude : \(altitude)"
                break
            case .error(let error):
                self.feedbackLabel.text = "failure: getTakeoffAltitude() \(error)"
            }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func getMaximumSpeedPressed(_ sender: Any) {
        let myRoutine = CoreManager.shared().drone.action.getMaximumSpeed()
        myRoutine.subscribe{ event in
                switch event {
                case .success(let maxSpeed):
                    self.feedbackLabel.text = "Maximum speed : \(maxSpeed)"
                    break
                case .error(let error):
                    self.feedbackLabel.text = "failure: getMaximumSpeed() \(error)"
                }
            }
            .disposed(by: disposeBag)
    }

    class func showAlert(_ message: String?, viewController: UIViewController?) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        viewController?.present(alert, animated: true) {() -> Void in }
    }
}


