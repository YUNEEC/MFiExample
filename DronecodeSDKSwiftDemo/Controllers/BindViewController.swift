//
//  BindViewController.swift
//  YuneecMFiExample
//
//  Created by Sushma Sathyanarayana on 5/24/18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import Foundation
import UIKit
import MFiAdapter

class BindViewController: UIViewController {
    
    @IBOutlet weak var scanWifi: UIButton!
    @IBOutlet weak var bind: UIButton!
    @IBOutlet weak var getBindingStatusButton: UIButton!
    @IBOutlet weak var unbindCameraButton: UIButton!
    @IBOutlet weak var unbindRCButton: UIButton!
    @IBOutlet weak var scanRCButton: UIButton!
    @IBOutlet weak var bindRCButton: UIButton!
    @IBOutlet weak var exitBindButton: UIButton!
    @IBOutlet weak var wifiList: UITableView!
    @IBOutlet weak var wifiSSIDText: UITextField!
    @IBOutlet weak var wifiPwdText: UITextField!
    
    var wifiSelected: String = ""
    var wifiPassword: String = ""
    var autoPilotId: String = ""
    
    var wifiArray = [YuneecRemoteControllerCameraWifiInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keyboard delegates
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        wifiList.delegate = self
        wifiList.dataSource = self
        wifiSSIDText.placeholder = "Wifi SSID"
        wifiPwdText.placeholder = "Wifi Password"
        // Configure Refresh
        // wifiList.refreshControl = refreshControl // unresolved identifier...
        
        // Configure Tableview
        wifiList.layer.borderColor = UIColor.lightGray.cgColor
        wifiList.layer.borderWidth = 0.4
        wifiList.layer.cornerRadius = 5
        
        // set corners for buttons
        scanWifi.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        bind.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        getBindingStatusButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        unbindCameraButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        unbindRCButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        scanRCButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        bindRCButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
        exitBindButton.layer.cornerRadius = UI_CORNER_RADIUS_BUTTONS
    }
    
    @IBAction func scanRC(_ sender: UIButton) {
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().scanAutoPilot { (error, ids) in
            
            if let error = error {
                    BindViewController.showAlert("Error scanning RC", message: error.localizedDescription, viewController: self)
            } else if let ids = ids {
                for id in ids {
                    self.autoPilotId = String(format: "%@", id as! CVarArg)
                    BindViewController.showAlert("RC Scanned", message: "Id is: \(self.autoPilotId)", viewController:self)
                }
            }
        }
    }
    
    @IBAction func bindRC(_ sender: UIButton) {
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().bindAutoPilot(self.autoPilotId) { (error) in
            if let error = error {
                BindViewController.showAlert("Error in rc binding to \(self.autoPilotId)", message: error.localizedDescription, viewController: self)
            } else {
                 BindViewController.showAlert("RC Binding to \(self.autoPilotId) Successful!", message: "No Error Returned", viewController: self)
            }
        }
    }
    
    @IBAction func scanWifi(_ sender: UIButton) {
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().scanCameraWifi { (error, wifis) in
            
            if let error = error {
                self.wifiArray.removeAll()
                BindViewController.showAlert("Error scanning wifi", message: error.localizedDescription, viewController: self)
            } else {
                self.wifiArray.removeAll()
                for wifi in wifis! {
                    self.wifiArray.append(wifi)
                }
                
                DispatchQueue.main.async {
                    self.wifiList.reloadData()
                }
            }
        }
    }
    
    @IBAction func bind(_ sender: UIButton) {
        view.endEditing(true)
        wifiSelected = wifiSSIDText.text!
        wifiPassword = wifiPwdText.text!
        
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().bindCameraWifi(wifiSelected, wifiPassword: wifiPassword) { (error) in
            
            if let error = error {
                BindViewController.showAlert("Error binding camera", message: error.localizedDescription, viewController: self)
            } else {
                BindViewController.showAlert("Pairing Successful!", message: "", viewController: self)
            }
            
            DispatchQueue.main.async {
                self.wifiPwdText.text = ""
                self.wifiSSIDText.text = ""
            }
        }
    }
    
    @IBAction func getBindStatus(_ sender: UIButton) {
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().getCameraWifiBindStatus { (error, wifiInfo) in
            
            if let error = error {
                BindViewController.showAlert("Error getting Bind Status", message: error.localizedDescription, viewController: self)
            } else if let wifiInfo = wifiInfo{
                BindViewController.showAlert("Binding to", message: "\(wifiInfo.ssid)", viewController: self)
            }
        }
    }
    
    @IBAction func unBind(_ sender: UIButton) {
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().unBindCameraWifi { (error) in
            if let error = error {
                 BindViewController.showAlert("Error unbinding camera", message: error.localizedDescription, viewController: self)
            } else {
                BindViewController.showAlert("UnBinding Successful!", message: "", viewController: self)
            }
        }
    }
    
    @IBAction func unBindRC(_ sender: UIButton) {
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().unBindRC { (error) in
            if let error = error {
                BindViewController.showAlert("Error unbinding RC", message: error.localizedDescription, viewController: self)
            } else {
                BindViewController.showAlert("UnBinding RC Successful", message: "", viewController: self)
            }
        }
    }
    
    @IBAction func exitBind(_ sender: UIButton) {
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().exitBind { (error) in
            if let error = error {
                BindViewController.showAlert("Error exiting Bind", message: error.localizedDescription, viewController: self)
            } else {
                BindViewController.showAlert("Exit Bind Successful!", message: "", viewController: self)
            }
        }
    }
}

extension BindViewController {
    class func showAlert(_ title: String?, message: String?, viewController: UIViewController?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        DispatchQueue.main.async {
            viewController?.present(alert, animated: true) {() -> Void in }
        }
    }
}

// MARK: - Keyboard
extension BindViewController {
    @objc func keyboardWasShown(notification: NSNotification){
        view.layoutIfNeeded()
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        view.layoutIfNeeded()
    }
}

// MARK: - Tableview
extension BindViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wifiArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wifiName")!
        cell.textLabel?.text = wifiArray[indexPath.row].ssid
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.wifiSSIDText.text = wifiArray[indexPath.row].ssid
    }
}
