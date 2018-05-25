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
    
    @IBAction func scanWifi(_ sender: UIButton) {
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().scanCameraWifi { (error, wifis) in
            
            if error != nil {
                self.wifiArray.removeAll()
                DispatchQueue.main.async {
                    BindViewController.showAlert(error, self)
                }
            } else {
                self.wifiArray.removeAll()
                for wifi in wifis {
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
        
        wifiSelected = wifiSSIDText.text
        wifiPassword = wifiPwdText.text
        
        MFiAdapter.MFiRemoteControllerAdapter.sharedInstance().bindCameraWifi(wifiSelected, password: wifiPassword, block: { (error) in
            let message = error != nil ? "Error biding camera: \(error!.localizedDescription)" : "Pairing Successful!"
            
            DispatchQueue.main.async {
                BindViewController.showAlert(message, viewController: self)
                self.wifiPwdText.text = ""
                self.wifiSSIDText.text = ""
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Keyboard delegates
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        wifiList.delegate = self
        wifiList.dataSource = self
        
        // Configure Refresh
        wifiList.refreshControl = refreshControl
        
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
}
