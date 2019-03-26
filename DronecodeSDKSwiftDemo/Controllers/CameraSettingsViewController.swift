//
//  CameraSettingsViewController.swift
//  YuneecMFiExample
//
//  Created by Douglas on 8/8/18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import UIKit
import Eureka
import Dronecode_SDK_Swift
import RxSwift

class CameraSettingsViewController: FormViewController {
    
    var manifestSection: Section!
    
    var currentSettings = Variable<[Camera.Setting]>([])
    var possibleSettingOptions = Variable<[Camera.SettingOptions]>([])
    
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityView.hidesWhenStopped = true
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CameraSettingsViewController.done))
        navigationItem.leftBarButtonItem = done
        
        manifestSection = Section()
        form +++ manifestSection
        
        let combinedObservable = Observable.merge([possibleSettingOptions.asObservable().map{ $0 as AnyObject }, currentSettings.asObservable().map{ $0 as AnyObject }])
        combinedObservable.asObservable()
            .subscribe { (_) in
                self.updatePossibleSettingsTable()
            }
            .disposed(by: disposeBag)
        
        // Anotacao: Test updating values
//        testUpdatingValues()
        
        form +++ Section()
    }
    

    func testUpdatingValues() {

        let vehicles = ["P4P", "Yuneec"]
        let cameras = ["P4P": ["X4S", "X5S", "X7"], "Yuneec": ["E90", "CGT"]]
        
        let initialValue = vehicles.first!
  
        manifestSection <<< PickerRow<String>() {
            $0.tag = "VehiclesTag"
            $0.title = "Vehicles"
            $0.options = vehicles
            $0.value = initialValue
            }.onChange({ (row) in
                let secondRow = self.form.rowBy(tag: "CamerasTag") as! PushRow<String>
                let value = row.value!
                secondRow.value = cameras[value]?.first
                secondRow.options = cameras[value]
                secondRow.reload()
            })
        
        manifestSection <<< PushRow<String>() {
            $0.tag = "CamerasTag"
            $0.title = "Cameras"
            $0.options = cameras[initialValue]
            $0.value = cameras[initialValue]!.first
            $0.selectorTitle = "Choose a Camera"
            }.onChange({ (row) in
                print("Selected Camera: \(row.value)")
            })
    }
    
    func updatePossibleSettingsTable() {
        manifestSection.removeAll()
        
        possibleSettingOptions.value.forEach { (setting) in
            
            manifestSection <<< PushRow<String>() {
                $0.tag = setting.settingID
                $0.title = setting.settingDescription
                $0.value = currentSettingOption(settingId: setting.settingID)?.optionDescription
                $0.options = setting.options.compactMap {  $0.optionDescription  }
                $0.onChange { [weak self] pushRow in
                    
                    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    activityView.hidesWhenStopped = true
                    
                    self?.tableView.tableHeaderView = activityView
                    activityView.startAnimating()
                    
                    if let optionID = (setting.options.filter { $0.optionDescription == pushRow.value }.first?.optionID) {
                        self?.setSettings(settingID: setting.settingID, optionID: optionID ) { (error) in
                            
                            activityView.stopAnimating()
                            if let error = error {
                                ActionsViewController.showAlert("Error setting \(String(describing: setting.settingDescription ?? "value")).", viewController: self)
                                NSLog("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                    // The warning "Result of call to 'onPresent' is unused will go away with the next Eureka release.
                    // See: https://github.com/xmartlabs/Eureka/pull/1605
                }.onPresent({ (from, to) in
                    to.enableDeselection = false
                })
            }
        }
    }
    
    func startSpinner() {
        self.tableView.tableHeaderView = activityView
        activityView.startAnimating()
    }
    
    func stopSpinner() {
      self.tableView.tableHeaderView = nil
        activityView.stopAnimating()
    }
    
    func setSettings(settingID: String, optionID: String, callback: @escaping (Swift.Error?) -> ()) {
        let option = Camera.Option(optionID: optionID, optionDescription: "")
        let setting = Camera.Setting(settingID: settingID, settingDescription: "", option: option)
        
        CoreManager.shared().drone.camera.setSetting(setting: setting)
            .do(onError: { (error: Swift.Error) in
                callback(error)
            }, onCompleted: {
                NSLog("Seting \(settingID) with option \(optionID) succeeded!")
                callback(nil)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }
    
    private func currentSettingOption(settingId: String) -> Camera.Option? {
        return currentSettings.value.filter { $0.settingID == settingId }.first?.option
    }
}
