//
//  PreviewViewController.swift
//  YuneecMFiExample
//
//  Created by Sushma Sathyanarayana on 2/21/19.
//  Copyright © 2019 Marjory Silvestre. All rights reserved.
//

import Foundation
import MFiAdapter

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var previewView: YuneecPreviewView!
    
    var videoStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: .UIApplicationDidEnterBackground, object: nil)
         notificationCenter.addObserver(self, selector: #selector(appWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        self.startVideo()
    }
    
    func startVideo() {
        if(!self.videoStarted) {
            MFiAdapter.MFiPreviewViewAdapter.sharedInstance().startVideo(self.previewView) { (result) in
                if let result = result {
                    print (result)
                }
            }
            self.videoStarted = true;
        }
    }
    
    func stopVideo() {
        if(self.videoStarted) {
            MFiAdapter.MFiPreviewViewAdapter.sharedInstance().stopVideo { (result) in
                if let result = result {
                    print (result)
                }
            }
            self.videoStarted = false;
        }
    }
        
    @objc func appMovedToBackground() {
        print("App moved to background!")
        MFiAdapter.MFiPreviewViewAdapter.sharedInstance().stopVideo { (result) in
            if let result = result {
                print (result)
            }
        }
        self.videoStarted = false;
    }
    
    @objc func appWillEnterForeground() {
        self.startVideo()
    }
    
}
