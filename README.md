# MFiExample

This is a minimal iOS example app on how to use the Dronecode SDK and connect wia MFi to the ST10C and the H520.
The app is based on the [Dronecode SDK Swift example app](https://github.com/Dronecode/DronecodeSDK-Swift/tree/master/SampleCode/SwiftSampleCode).

## Instructions

1. Get the repository:
   ```
   git clone git@github.com:YUNEEC/MFiExample.git
   cd MFiExample
   ```

2. Get [MFiAdapter](https://github.com/YUNEEC/MFiAdapter/):
   - Either using `carthage update --platform ios --use-ssh` (if you have access).
   - Or by downloading the MFiAdapter frameworks from the [H520 update page](https://d3qzlqwby7grio.cloudfront.net/H520/index).

3. Open the workspace MFiExample.xcworkspace in XCode.

4. Try to build and run the project.

**Note: The paths set in the XCode project are for the carthage install way, so the frameworks need to be in `Carthage/Build/iOS/`. If you're using the manual download, re-add the frameworks to "Embedded Binaries".**
