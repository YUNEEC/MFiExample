//
//  DualVideoViewController.swift
//  YuneecMFiExample
//
//  Created by tbago on 2019/8/9.
//  Copyright © 2019 Marjory Silvestre. All rights reserved.
//

import UIKit
import MFiAdapter

class DualVideoViewController: UIViewController {

    @IBOutlet weak var preivewView: YuneecPreviewView!
    @IBOutlet weak var startSingleVideoButton: UIButton!
    @IBOutlet weak var startDualVideoButton: UIButton!
    @IBOutlet weak var stopVideoButton: UIButton!

    var videoStarted = false

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: .UIDeviceOrientationDidChange, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }

    @IBAction func startSingleVideo(_ sender: UIButton) {
        self.setDisplayRect()
        MFiAdapter.MFiPreviewViewAdapter.sharedInstance().startVideo(self.preivewView) { (result) in
            if let result = result {
                print(result)
            }
        }
        self.startSingleVideoButton.isEnabled = false
        self.startDualVideoButton.isEnabled = false
        self.stopVideoButton.isEnabled = true
    }

    @IBAction func startDualVideo(_ sender: UIButton) {
        self.setDisplayRect()
        MFiAdapter.MFiPreviewViewAdapter.sharedInstance().startDualVideo(self.preivewView) { (result) in
            if let result = result {
                print(result)
            }
        }
        self.startSingleVideoButton.isEnabled = false
        self.startDualVideoButton.isEnabled = false
        self.stopVideoButton.isEnabled = true
    }

    @IBAction func stopVideo(_ sender: UIButton) {
        MFiAdapter.MFiPreviewViewAdapter.sharedInstance().stopVideo { (result) in
            if let result = result {
                print (result)
            }
        }
        self.startSingleVideoButton.isEnabled = true
        self.startDualVideoButton.isEnabled = true
    }

    func setDisplayRect() {
        let rect = CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: self.preivewView.bounds.size
        )

        MFiAdapter.MFiPreviewViewAdapter.sharedInstance().updateDisplay(rect)
    }

    @objc func orientationChanged() {
        self.setDisplayRect()
    }
}
