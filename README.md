SmileViewController
===================================

UIViewController that allows to detect smile in real time (AVFoundation and CoreImage). There are additional features like photo sharing (Facebook, Twitter). It's also possible to take new selfie by pressing re-take button.

##Notes
- Project uses AVFoundation Framework.
- Application will work only on iOS 8 and higher. 
- Application uses ARC.

##Usage

To use this view controller simply load it up from AppDelegate:
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    SmileViewController *smileViewController = [SmileViewController new];
    self.window.rootViewController = smileViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}
```
##Example
![Screen1](https://raw.githubusercontent.com/MaximAlien/SmileViewController/master/resources/example.png)
