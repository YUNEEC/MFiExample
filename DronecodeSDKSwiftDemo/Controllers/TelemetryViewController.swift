//
//  TelemetryViewController.swift
//  DronecodeSDKSwiftDemo
//
//  Created by Marjory Silvestre on 05.04.18.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import UIKit
import Dronecode_SDK_Swift
import RxSwift

class TelemetryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    // MARK: - IBOutlets
    @IBOutlet weak var connectionLabel: UILabel!
    @IBOutlet weak var telemetryTableView: UITableView!
    
    // MARK: - Properties
    private var telemetry_entries: TelemetryEntries?
    private var timer: Timer?

    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connectionLabel.text = "Starting system ..."
        
        //TableView set datasource and delegate
        self.telemetryTableView.delegate = self
        self.telemetryTableView.dataSource = self
        
        // Start System
        CoreManager.shared().start()

        // Telemetry entries
        // FIXME: we need this sleep because we can't subscribe in telemetry
        //        before telemetry is initialized.
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.telemetry_entries = TelemetryEntries()
//        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:  #selector(updateView), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRcEventNotification(notification:)),
            name: Notification.Name("RemoteControllerKeyNotification"),
            object: nil)
    }
    
    @objc func handleRcEventNotification(notification: NSNotification) {
        TelemetryViewController.showAlert("RC Button Pressed: ", message: notification.userInfo!["eventId"] as? String , viewController: self)
        if (notification.userInfo!["eventValue"] as? Int == 1) {
            if (notification.userInfo!["eventId"]  as? String == "Camera Button")
                || (notification.userInfo!["eventId"]  as? String == "Video Button"){
                CameraUtility.sharedInstance().handleRcButton(key: (notification.userInfo!["eventId"]  as? String)!)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    // MARK: - TableView
    @objc func updateView(_ _timer: Timer?) {
        let entry = telemetry_entries?.entries[EntryType.connection.rawValue]
        if entry != nil {
            connectionLabel.text = entry?.state == 1 ? "Connected" : "Disconnected"
        } else {
            connectionLabel.text = "No information about connection"
        }
        telemetryTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let entriesCount = telemetry_entries?.entries.count {
            return entriesCount
        }
        return 0
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TelemetryCell", for: indexPath)
        
        let count_entries : Int = (telemetry_entries?.entries.count) ?? 0
        if (count_entries > 0) {
            if let entry = telemetry_entries?.entries[indexPath.row] {
                cell.textLabel?.text = entry.value;
                cell.detailTextLabel?.text = entry.property;
            }
        }
        
        return cell
    }

    // MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TelemetryViewController {
    class func showAlert(_ title: String?, message: String?, viewController: UIViewController?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            viewController?.present(alert, animated: true) {() -> Void in }
        }
    }
}

