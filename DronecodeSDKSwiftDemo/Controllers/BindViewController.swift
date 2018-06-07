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
    @IBOutlet weak var wifiList: UITableView!
    @IBOutlet weak var wifiSSIDText: UITextField!
    @IBOutlet weak var wifiPwdText: UITextField!
    
    var wifiSelected: String = ""
    var wifiPassword: String = ""
    
    var wifiArray = [YuneecRemoteControllerCameraWifiInfo]()
    
    @IBAction func scanRC(_ sender: UIButton) {
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().scanAutoPilot { (error, ids) in
            
            if error != nil {
                DispatchQueue.main.async {
                    BindViewController.showAlert(error as? String, viewController: self)
                }
            } else {
                for id in ids! {
                    print(id);
                }
            }
        }
    }
    
    @IBAction func bindRC(_ sender: UIButton) {
        let autoPilotId: String = ""
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().bindAutoPilot(autoPilotId) { (error) in
            let message = error != nil ? "Error in rc binding: \(error!.localizedDescription)" : "RC Binding Successful!"
            
            DispatchQueue.main.async {
                BindViewController.showAlert(message, viewController: self)
            }
        }
    }
    
    @IBAction func scanWifi(_ sender: UIButton) {
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().scanCameraWifi { (error, wifis) in
            
            if error != nil {
                self.wifiArray.removeAll()
                DispatchQueue.main.async {
                    BindViewController.showAlert(error as? String, viewController: self)
                }
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
            let message = error != nil ? "Error binding camera: \(error!.localizedDescription)" : "Pairing Successful!"
            
            DispatchQueue.main.async {
                BindViewController.showAlert(message, viewController: self)
                self.wifiPwdText.text = ""
                self.wifiSSIDText.text = ""
        }
      }
    }
    
    @IBAction func getBindStatus(_ sender: UIButton) {
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().getCameraWifiBindStatus { (error, wifiInfo) in
            if error != nil {
                DispatchQueue.main.async {
                    BindViewController.showAlert(error as? String, viewController: self)
                }
            } else {
                BindViewController.showAlert("Binding to: \(wifiInfo!.ssid)" , viewController: self)
            }
        }
    }
    
    @IBAction func unBind(_ sender: UIButton) {
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().unBindCameraWifi { (error) in
            let message = error != nil ? "Error unbinding camera" : "UnBinding Successful!"
            
            DispatchQueue.main.async {
                BindViewController.showAlert(message, viewController: self)
            }
        }
    }
    
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension BindViewController {
    class func showAlert(_ message: String?, viewController: UIViewController?) {
        let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        viewController?.present(alert, animated: true) {() -> Void in }
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
