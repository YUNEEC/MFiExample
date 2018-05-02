# MFiExample

This should be a minimal example app on how to connect wia MFi to the ST10C and the H520.

## Instructions

1. Get the repository:
   ```
   git clone git@github.com:YUNEEC/MFiExample.git
   cd MFiExample
   git submodule update --init --recursive
   ```


2. Install CocoaPods:
   ```
   pod install
   ```
3. Open the workspace MFiExample.xcworkspace in XCode 9.2.

4. Try to build the project.
   If you get errors that CocoaAsyncSocket.framework can't be found, search for
   it in your home folder and drag it into "Embedded Binaries" of the `YuneecMFiExample`.
