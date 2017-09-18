SmileViewController
===================================

[![Build Status](https://travis-ci.org/MaximAlien/SmileViewController.svg?branch=master)](https://travis-ci.org/MaximAlien/SmileViewController)
[![codecov](https://codecov.io/gh/MaximAlien/SmileViewController/branch/master/graph/badge.svg)](https://codecov.io/gh/MaximAlien/SmileViewController)
[![CocoaPods](https://img.shields.io/cocoapods/v/SmileViewController.svg)](https://cocoapods.org/?q=name%3Asmileviewcontroller*)

UIViewController that allows to detect smile in real time (AVFoundation, CoreImage). It's also possible to take new selfie by pressing re-take button.

## Installation with CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like SmileViewController in your projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

## Podfile

To integrate SmileViewController into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
pod 'SmileViewController', '~> 1.0.1'
end
```

Then, run the following command:

```bash
$ pod install
```

## Notes
- Project uses AVFoundation Framework.
- Application will work only on iOS 8 and higher. 
- Application uses ARC.

## Usage

To use this view controller simply load it up from AppDelegate:
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    SmileViewController *smileViewController = [SmileViewController new];
    self.window.rootViewController = smileViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}
```
## Example
![Screen1](https://raw.githubusercontent.com/MaximAlien/SmileViewController/master/resources/example.png)
