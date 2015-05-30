Smile-Detector-CameraViewController
===================================

CameraViewController that allows to detect smile in real time (AVFoundation and CIFaceFeature). There are additional features like photo sharing (Facebook, Twitter, Instagram). It's also possible to take new selfie by pressing Re-take button.

Project uses AVFoundation Framework.

Application will work only on iOS 7 and higher. ARC is required.
 
##Usage

To use this view controller simply load it up from AppDelegate:
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    SmileCameraViewController *smileCameraViewController = [[SmileCameraViewController alloc] initWithNibName:@"SmileCameraViewController" bundle:nil];
    self.window.rootViewController = smileCameraViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}
```
##Example
![Screen1](https://raw.githubusercontent.com/MaximAlien/Smile-Detector-CameraViewController/master/resources/example.png)
