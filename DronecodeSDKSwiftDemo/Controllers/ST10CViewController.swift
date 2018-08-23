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

class ST10CViewController: UIViewController {
    
    @IBOutlet weak var mfiStatus: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mfiStatus.text = "View officially loaded"
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(handleConnectionStateNotification(notification:)),
//            name: Notification.Name("MFiConnectionStateNotification"),
//            object: nil)        
    }
    
    @IBAction func fetchMediaAction(_ sender: UIButton) {
        fetchMediaList()
    }
    
    func fetchMediaList() {
        MFiAdapter.MFiCameraAdapter.sharedInstance().requestMediaInfo { [weak self] (array, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self?.mfiStatus.text = String(describing: array)
                }
            } else {
                DispatchQueue.main.async {
                    self?.mfiStatus.text = String(describing: error)
                }
            }
        }
    }
    
    @objc func handleConnectionStateNotification(notification: NSNotification) {
        mfiStatus.text = String(describing:notification.userInfo)
    }
}



