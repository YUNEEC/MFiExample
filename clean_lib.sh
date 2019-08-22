#! /bin/bash
set -e

framework_list="BaseFramework FFMpegDecoder FFMpegDemuxer FFMpegLowDelayDecoder FFMpegLowDelayDemuxer MediaBase YuneecCameraSDK YuneecDataTransferManager YuneecDecoder YuneecMFiDataTransfer YuneecMediaPlayer YuneecPreviewView YuneecRemoteControllerSDK YuneecWifiDataTransfer"

for framework in $framework_list
do
    src=./Carthage/Checkouts/Yuneec-MFiAdapter/${framework}.framework/$framework

    lipo $src -thin armv7 -output ${framework}_armv7
    lipo $src -thin arm64 -output ${framework}_arm64
    lipo -create ${framework}_armv7 ${framework}_arm64 -output $framework
    mv $framework ./Carthage/Checkouts/Yuneec-MFiAdapter/${framework}.framework/$framework
    rm ${framework}_armv7
    rm ${framework}_arm64
done

framework_list="AFNetworking CocoaAsyncSocket MAVSDK_Swift Eureka RxSwift CgRPC BoringSSL RxAtomic RxBlocking RxCocoa RxTest SwiftGRPC SwiftProtobuf backend"
for framework in $framework_list
do
    src=./Carthage/Build/iOS/${framework}.framework/$framework

    lipo -remove i386 "$src" -output "$src"
    lipo -remove x86_64 "$src" -output "$src"
done
