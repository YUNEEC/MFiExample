# MFiExample

This is a minimal iOS example app on how to use the Dronecode SDK and connect via MFi to the ST10C Remote Controller and the H520.
The app is based on the [Dronecode SDK Swift example app](https://github.com/Dronecode/DronecodeSDK-Swift-Example). 

## Instructions

1. Get the repository:
   ```
   git clone git@github.com:YUNEEC/MFiExample.git
   cd MFiExample
   ```

2. Get frameworks.    
   using `carthage update --platform ios --use-ssh` to checkout and build framework.
   Prebuilt frameworks are under `Carthage/Checkouts/Yuneec-MFiAdapter`.

3. Open the workspace MFiExample.xcworkspace in XCode.

4. Try to build and run the project.


