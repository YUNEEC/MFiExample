//
//  GalleryUtility.swift
//  YuneecMFiExample
//
//  Created by Joe Zhu on 2018/8/17.
//  Copyright © 2018年 Marjory Silvestre. All rights reserved.
//

import Foundation
import Photos

class GalleryUtility {

    init() {
        let fileManager = FileManager.default
        let path:String = self.getLocalMediaPath()
        let exist = fileManager.fileExists(atPath: path)

        if !exist {
            try! fileManager.createDirectory(atPath: path, withIntermediateDirectories: true,
                                             attributes: nil)
        }

        createAlbum(albumName: getAlbumName())
    }

    func getLocalMediaPath() -> String {
        return NSTemporaryDirectory() + "media"
    }

    func getLocalMediaFilePath(fileName:String) -> String {
        return self.getLocalMediaPath() + "/" + fileName
    }

    func isMediaFileExist(fileName:String) -> Bool {
        let fileManager = FileManager.default
        let filepath = self.getLocalMediaFilePath(fileName: fileName)

        return fileManager.fileExists(atPath: filepath)
    }

    func getLocalMediaFileCount() -> Int {
        let fileManager = FileManager.default
        let path:String = self.getLocalMediaPath()
        let contentsOfPath = try? fileManager.contentsOfDirectory(atPath: path)

        return contentsOfPath!.count
    }

    func removeAllLocalMediaFile() {
        let fileManager = FileManager.default
        let path:String = self.getLocalMediaPath()
        let fileArray = fileManager.subpaths(atPath: path)

        for file in fileArray! {
            try? fileManager.removeItem(atPath: path + "/\(file)")
        }
    }

    func isAuthorized() -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()

        return authStatus == .authorized
    }

    func getAlbumName() -> String {
        return "MFiExample"
    }

    func getAlbum(albumName: String = "") -> PHAssetCollection? {
        var assetAlbum: PHAssetCollection?
        let list = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)

        list.enumerateObjects({ (album, index, stop) in
            let assetCollection = album
            if albumName == assetCollection.localizedTitle {
                assetAlbum = assetCollection
                stop.initialize(to: true)
            }
        })

        return assetAlbum
    }

    func createAlbum(albumName: String = "") {
        let authStatus = PHPhotoLibrary.authorizationStatus()

        if (authStatus == .notDetermined) {
            PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
                self.createAlbum(albumName: albumName)
            }
        } else if (authStatus != .authorized){
            return
        }

        let assetAlbum: PHAssetCollection? = getAlbum(albumName: albumName)

        if (assetAlbum != nil) {
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
        }, completionHandler: { (isSuccess, error) in
            if (isSuccess) {
                print("create album success")
            }
        })
    }

    func saveImageToAlbum(image: UIImage) {
        if !self.isAuthorized() {
            return
        }

        let assetAlbum: PHAssetCollection? = getAlbum(albumName: getAlbumName())

        PHPhotoLibrary.shared().performChanges({
            let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = result.placeholderForCreatedAsset
            let albumChangeRequset = PHAssetCollectionChangeRequest(for: assetAlbum!)

            albumChangeRequset!.addAssets([assetPlaceholder!]  as NSArray)
        }) { (isSuccess: Bool, error: Error?) in
            if (isSuccess) {
                print("add media file to album success")
            }
        }
    }

    func addAllFileToAlbum() {
        let fileManager = FileManager.default
        let path:String = self.getLocalMediaPath()
        let fileArray = fileManager.subpaths(atPath: path)

        var image:UIImage

        for file in fileArray! {
            image = UIImage(contentsOfFile: path + "/\(file)" )!
            saveImageToAlbum(image: image)
        }
    }
}
