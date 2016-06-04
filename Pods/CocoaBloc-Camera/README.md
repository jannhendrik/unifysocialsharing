# CocoaBloc-Camera

[![CI Status](http://img.shields.io/travis/stagebloc/CocoaBloc-Camera.svg?style=flat)](https://travis-ci.org/stagebloc/CocoaBloc-Camera/branches)
[![Version](https://img.shields.io/cocoapods/v/CocoaBloc-Camera.svg?style=flat)](http://cocoapods.org/pods/CocoaBloc-Camera)
[![License](https://img.shields.io/cocoapods/l/CocoaBloc-Camera.svg?style=flat)](http://cocoapods.org/pods/CocoaBloc-Camera)
[![Platform](https://img.shields.io/cocoapods/p/CocoaBloc-Camera.svg?style=flat)](http://cocoapods.org/pods/CocoaBloc-Camera)

## Installation

CocoaBloc-Camera is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'CocoaBloc-Camera'
```

## Getting Started
#### Implementing CococaBloc-Camera:
1. Init a `SBCameraViewController`
2. Set the `SBCameraViewController's` `delegate`.
3. Present the `SBCameraViewController`.
4. Handle `SBCaptureViewControllerDelegate` callbacks.

#### Example Implementation
```objc
@implementation ViewController

. . .

//create an SBCameraViewController
- (void)launchCameraController {
    // ===> 1. Init a `SBCameraViewController`
    SBCameraViewController *cameraController = [[SBCameraViewController alloc] initWithReviewOptions:reviewOptions initialCaptureType:SBCaptureTypeVideo];

    // ===> 2. Set the `SBCameraViewController's` `delegate`.
    cameraController.captureDelegate = self;

    // ===> 3. Present the `SBCameraViewController`.
    [self presentViewController:cameraController animated:YES completion:nil];
}

. . .

// ===> 4. Handle `SBCaptureViewControllerDelegate` callbacks.
#pragma mark - SBCaptureViewControllerDelegate
- (void)cameraControllerCancelled:(SBCaptureViewController*)controller {
    //The user just attempted to close the controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

//The SBCaptureViewControllerDelegate protocol inherits from SBReviewControllerDelegate
//hence the different name "reviewController:..."
- (void)reviewController:(SBReviewController*)controller acceptedAsset:(SBAsset*)asset {

    //The user just accepted the SBAsset, do something with it!

    //This is also a good time to dismiss the SBCameraViewController you launched earlier.
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
```


## Trying the Example Project
To try our example project, run the following via command line:
```ruby
pod try 'CocoaBloc-Camera'
```

## License

CocoaBloc-Camera is available under the MIT license. See the LICENSE file for more info.
