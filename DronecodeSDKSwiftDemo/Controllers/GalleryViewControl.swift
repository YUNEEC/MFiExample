//
//  GalleryViewControl.swift
//  YuneecMFiExample
//
//  Created by Joe Zhu on 2018/8/13.
//  Copyright © 2018 Marjory Silvestre. All rights reserved.
//

import Foundation
import UIKit
import MFiAdapter

class GalleryViewController: UIViewController {

    @IBOutlet weak var download: UIButton!
    @IBOutlet weak var refresh: UIButton!
    @IBOutlet weak var cameraMediaNum: UILabel!
    @IBOutlet weak var localMediaNum: UILabel!
    @IBOutlet weak var waiting: UIActivityIndicatorView!
    @IBOutlet weak var fileInfo: UILabel!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var remove: UIButton!

    var mediaArray:Array<Any>!
    var utility:GalleryUtility!

    @IBAction func refresh(_ sender: UIButton) {
        self.waiting.startAnimating()
        self.refresh.isEnabled = false
        self.download.isEnabled = false
        self.remove.isEnabled = false
        self.cancel.isEnabled = false
        MFiAdapter.MFiCameraAdapter.sharedInstance().requestMediaInfo { (array, error) in
            DispatchQueue.main.async {
                self.refresh.isEnabled = true
                self.download.isEnabled = true
                self.remove.isEnabled = true
                self.waiting.stopAnimating()
                if (error == nil) {
                    self.mediaArray = array
                    self.cameraMediaNum.text = "camera:" + String(format:"%02d", (array?.count)!)
                } else {
                    BindViewController.showAlert(error?.localizedDescription, viewController:self)
                }
            }
        }
    }

    @IBAction func download(_ sender: UIButton) {
        if (self.mediaArray == nil) {
            BindViewController.showAlert("refresh first", viewController:self)
            return
        }

        if (self.mediaArray!.count == 0) {
            BindViewController.showAlert("no media file", viewController:self)
        } else {
            var downloadArray:Array<MFiMediaDownload> = Array()
            let download:MFiMediaDownload = MFiMediaDownload.init()
            for media in self.mediaArray {
                download.media = media as! YuneecMedia
                download.filePath = self.utility.getLocalMediaFilePath(fileName: download.media.fileName)
                download.isThumbnail = false
                download.isPreviewVideo = false

                if (self.utility.isMediaFileExist(fileName: download.media.fileName) == false) {
                    downloadArray.append(download.copy() as! MFiMediaDownload)
                }
            }

            self.refresh.isEnabled = false
            self.download.isEnabled = false
            self.remove.isEnabled = false
            self.cancel.isEnabled = true
            self.fileInfo.text = ""
            self.fileInfo.isHidden = false

            let total:Int = downloadArray.count
            MFiAdapter.MFiCameraAdapter.sharedInstance().isCancel = false
            MFiAdapter.MFiCameraAdapter.sharedInstance().downloadMediasArray(downloadArray, progress: { (index, fileName, fileSize, progress) in
                DispatchQueue.main.async {
                    self.fileInfo.text = "(" + String(Int(index)) + "/" +  String(Int(total)) + ")" + fileName! + "[" + String(format:"%.2f", Float(Float(String(fileSize!))! / 1024 / 1024)) + "M]" + String(Int(progress * 100)) + "%"
                    self.localMediaNum.text = "local:" + String(self.utility.getLocalMediaFileCount())
                }
            }, complete: { (error) in
                DispatchQueue.main.async {
                    self.localMediaNum.text = "local:" + String(self.utility.getLocalMediaFileCount())
                    self.refresh.isEnabled = true
                    self.download.isEnabled = true
                    self.remove.isEnabled = true
                    self.cancel.isEnabled = false
                    self.fileInfo.isHidden = true
                    self.utility.addAllFileToAlbum()
                    if (error != nil) {
                        BindViewController.showAlert(error?.localizedDescription, viewController:self)
                    }
                }
            })
         }
    }

    @IBAction func cancel(_ sender: UIButton) {
        MFiAdapter.MFiCameraAdapter.sharedInstance().isCancel = true
    }

    @IBAction func removeLocal(_ sender: UIButton) {
        self.utility.removeAllLocalMediaFile()
        self.localMediaNum.text = "local:" + String(self.utility.getLocalMediaFileCount())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.utility = GalleryUtility()
        self.cameraMediaNum.text = "camera:" + String(0)
        self.localMediaNum.text = "local:" + String(self.utility.getLocalMediaFileCount())
        self.fileInfo.text = ""
        self.cancel.isEnabled = false
    }
}


