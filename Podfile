platform :ios, '11.0'
use_frameworks!

workspace 'MFiExample'

def common_pods
    pod 'CocoaAsyncSocket'
end

target :'YuneecMFiExample' do
    project 'YuneecMFiExample'
    common_pods
end

target :'MFiAdapter' do
    project 'MFiAdapter/MFiAdapter.xcodeproj'
    common_pods
end

target :'YuneecWifiDataTransfer' do
    project 'MFiAdapter/YuneecDataTransfer/YuneecWifiDataTransfer/YuneecWifiDataTransfer.xcodeproj'
    common_pods
end

target :'YuneecMFiDataTransfer' do
    project 'MFiAdapter/YuneecDataTransfer/YuneecMFiDataTransfer/YuneecMFiDataTransfer.xcodeproj'
    common_pods
end
