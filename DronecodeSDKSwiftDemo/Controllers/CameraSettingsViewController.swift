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

private func setupEurekaDefaults() {
    SwitchRow.defaultCellUpdate = { cell, row in
        cell.textLabel?.textColor = UIColor.black
    }
    
    ButtonRow.defaultCellUpdate = { cell, row in
        cell.textLabel?.textColor = UIColor.black
    }
    
    LabelRow.defaultCellUpdate = { cell, row in
        cell.textLabel?.textColor = UIColor.black
    }
}

class CameraSettingsViewController: FormViewController {
    
    var manifestSection: Section!
    
    var currentSettings = Variable<[Setting]>([])
    var possibleSettingOptions = Variable<[SettingOptions]>([])
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEurekaDefaults()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CameraSettingsViewController.done))
        navigationItem.leftBarButtonItem = done

        
        manifestSection = Section()
        form +++ manifestSection
        
        let combimedObservable = Observable.merge([possibleSettingOptions.asObservable().map{ $0 as AnyObject }, currentSettings.asObservable().map{ $0 as AnyObject }])
        combimedObservable.asObservable().subscribe { (_) in
            self.updatePossibleSettingsTable()
        }.disposed(by: disposeBag)
        
        form +++ Section()
        <<< ButtonRow() {
            $0.title = "Restore Default Settings"
            }
            .onCellSelection() {
                _,_  in
                
//                self.manifestSection.removeAll()
                
                defaultCameraSettings.forEach { (setting, optionID) in
                    
                    self.setSettings(settingID: setting.stringValue , optionID: optionID) { (error) in
                        if let error = error {
                            NSLog("Error: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
    
    func updatePossibleSettingsTable() {
        manifestSection.removeAll()
        
        possibleSettingOptions.value.forEach { (setting) in
            
            guard let settingsType = DronecodeCameraSettings(rawValue: setting.settingId)?.settingsType else {
                NSLog("Type is not implemented yet")
                return
            }
            
            manifestSection <<< PushRow<String>() {
                    $0.tag = setting.settingId
                    $0.title = DronecodeCameraSettings(rawValue: setting.settingId)?.stringRepresentation ?? "N/A"
                    $0.options = setting.options.compactMap {  settingsType.init(rawValue: $0.id)?.description  }
                    let optionID = currentSettings.value.filter { $0.id == setting.settingId }.first?.option.id
                    if let optionID = optionID {
                        $0.value = settingsType.init(rawValue: optionID)?.description ?? "N/A"
                    } else {
                        $0.value = "N/A"
                    }
                    let originalValue = $0.value
                    $0.onChange { pushRow in
                        
                        guard let value = pushRow.value, let newSettingValue = settingsType.rawValue(from: value) else {
                            NSLog("Error: Settings value not supported")
                            return
                        }

                        // Show spinner
                        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                        self.tableView.backgroundView = activityView
                        activityView.startAnimating()
                        
                        self.setSettings(settingID: setting.settingId, optionID: newSettingValue) { (error) in
                            // Hide spinner
                            if let error = error {
                                ActionsViewController.showAlert("Error setting \(String(describing: DronecodeCameraSettings(rawValue: setting.settingId)!.stringRepresentation)).", viewController: self)
                                NSLog("Error: \(error.localizedDescription)")
                            } else {
                                self.tableView.backgroundView = nil
                                self.manifestSection.removeAll()
                            }
                        }
                    }
                }
        }
    }
    
    func setSettings(settingID: String, optionID: String, callback: @escaping (Swift.Error?) -> ()) {
        let option = Option(id: optionID)
        let setting = Setting(id: settingID, option: option)
        
        let setSettings = CoreManager.shared().camera.setSetting(setting: setting)
            .do(onError: { (error: Swift.Error) in
                callback(error)
            }, onCompleted: {
                NSLog("Set settings succeeded!")
            })
        
        let _ = setSettings.subscribe()
    }
    
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }
}
