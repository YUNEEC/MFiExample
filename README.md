# MFiExample

This should be a minimal example app on how to connect wia MFi to the ST10C and the H520.

## Instructions

1. Create an XCode workspace.
2. Add the MFiExampleto it.
3. Drag the framework projects that can be found in the Yuneec-App repository:
   - FFMpegLowDelayDemuxer
   - FFmpegDemuxer
   - FFmpegLowDelayDecoder
   - FFmpegDecoder
   - MediaBase
   - BaseFramework
   - YuneecDataTransferManager
   - YuneecMFiDataTransfer
   - YuneecWifiDataTransfer
4. Add the products of all frameworks pulled in above to "Embedded Binaries" of MFiExample.
5. Run `carthage update`
6. Add `Carthage/Build/iOS/CocoaAsyncSocket.framework` also to "Embedded Binaries" of MFiExample.

