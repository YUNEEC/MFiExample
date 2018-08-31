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
    
    var currentSettings = Variable<[Setting]>([])
    var possibleSettingOptions = Variable<[SettingOptions]>([])
    
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
        
        form +++ Section()
    }
    
    func updatePossibleSettingsTable() {
        manifestSection.removeAll()
        
        possibleSettingOptions.value.forEach { (setting) in
            
            manifestSection <<< PushRow<String>() {
                $0.tag = setting.settingId
                $0.title = setting.settingDescription
                $0.value = currentSettingOption(settingId: setting.settingId)?.description
                $0.options = setting.options.compactMap {  $0.description  }
                $0.onChange { [weak self] pushRow in
                    
                    let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                    activityView.hidesWhenStopped = true
                    
                    self?.tableView.tableHeaderView = activityView
                    activityView.startAnimating()
                    
                    if let optionID = (setting.options.filter { $0.description == pushRow.value }.first?.id) {
                        self?.setSettings(settingID: setting.settingId, optionID: optionID ) { (error) in
                            
                            activityView.stopAnimating()
                            if let error = error {
                                ActionsViewController.showAlert("Error setting \(String(describing: setting.settingDescription ?? "value")).", viewController: self)
                                NSLog("Error: \(error.localizedDescription)")
                            }
                        }
                    }
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
        let option = Option(id: optionID)
        let setting = Setting(id: settingID, option: option)
        
        CoreManager.shared().camera.setSetting(setting: setting)
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
    
    private func currentSettingOption(settingId: String) -> Option? {
        return currentSettings.value.filter { $0.id == settingId }.first?.option
    }
}
