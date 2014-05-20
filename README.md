Smile-Detector-CameraViewController
===================================

CameraViewController which allows to detect users' smile and share picture via social services (Facebook, Twitter).

ViewController allows to analyze in real time face features (using CIFaceFeature class) and takes screenshot when user smiled. After that it's possible to share taken selfie via Facebook, Twitter and Instagram.

Project uses AVFoundation Framework.

Application will work only on iOS 7 and higher.
 
##Usage

To use this view controller simply load it up from AppDelegate:
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    
    SmileCameraViewController *smileCameraViewController = [[SmileCameraViewController alloc]     initWithNibName:@"SmileCameraViewController" bundle:nil];
    self.window.rootViewController = smileCameraViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}
```
##Example
![Screen1](https://raw.githubusercontent.com/MaximAlien/Smile-Detector-CameraViewController/master/resources/example2.png)
