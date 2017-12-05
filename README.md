SmileViewController
===================================

[![Build Status](https://travis-ci.org/MaximAlien/SmileViewController.svg?branch=master)](https://travis-ci.org/MaximAlien/SmileViewController)
[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/SmileViewController.svg)](https://cocoapods.org/?q=name%3Asmileviewcontroller*)

UIViewController which allows to detect smile in real time.

## Installation with CocoaPods
[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like SmileViewController in your projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

### Podfile

To integrate SmileViewController into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'

target 'TargetName' do
pod 'SmileViewController', '~> 1.0.8'
end
```

Then, run the following command:

```bash
$ pod install
```

## Installation with Carthage
To install [Carthage](https://github.com/Carthage/Carthage) run following command:
```bash
$ brew install carthage
```

### Cartfile
1. To integrate SmileViewController into your Xcode project using Carthage, specify it in your `Cartfile`:
```ruby
github "MaximAlien/SmileViewController" ~> 1.0.8
```

2. Then, run the following command:
```bash
$ carthage update
```

3. On your application targets’ *General* settings tab, in the *Linked Frameworks and Libraries* section, drag and drop SmileViewCtrlr.framework you want to use from the Carthage/Build folder on disk.

4. On your application targets’ *Build Phases* settings tab, click the *+* icon and choose *New Run Script Phase*. Create a Run Script in which you specify your shell (ex: /bin/sh), add the following contents to the script area below the shell:
```bash
/usr/local/bin/carthage copy-frameworks
```

5. Add path to the framework you want to use under *Input Files*: $(SRCROOT)/Carthage/Build/iOS/SmileViewCtrlr.framework
6. Add path to the copied frameworks to the *Output Files*, e.g.: $(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/SmileViewCtrlr.framework

## Usage

To use this view controller simply load it up from AppDelegate:
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    SmileViewController *smileViewController = [SmileViewController new];
    // or (in case when using Carthage)
    SmileViewController *smileViewController = [[SmileViewController alloc] initWithNibName:@"SmileViewController" bundle:[NSBundle bundleForClass:SmileViewController.class]];
    self.window.rootViewController = smileViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}
```
## Example
![Screen1](https://raw.githubusercontent.com/MaximAlien/SmileViewController/master/resources/example.gif)
