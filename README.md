# mParticle Apple Kit Library

A kit is an extension to the core [mParticle Apple SDK](https://github.com/mParticle/mparticle-apple-sdk). A kit works as a bridge between the mParticle SDK and a partner SDK. It abstracts the implementation complexity, simplifying the implementation for developers.

A kit takes care of initializing and forwarding information depending on what you've configured in [your app's dashboard](https://app.mparticle.com), so you just have to decide which kits you may use prior to submission to the App Store. You can easily include all of the kits, none of the kits, or individual kits – the choice is yours.

[![CocoaPods compatible](http://img.shields.io/badge/CocoaPods-compatible-brightgreen.png)](https://cocoapods.org/?q=mparticle)
[![Carthage compatible](http://img.shields.io/badge/Carthage-compatible-brightgreen.png)](https://github.com/Carthage/Carthage)


## Installation

Please refer to installation instructions in the core mParticle Apple SDK [README](https://github.com/mParticle/mparticle-apple-sdk#get-the-sdk), or check out our [SDK Documentation](http://docs.mparticle.com/#mobile-sdk-guide) site to learn more.

## Deep-linking

When working with deep-linking register to observe the `mParticleKitDidBecomeActiveNotification` notification, and implement the `application:continueUserActivity:restorationHandler:` UIApplicationDelegate method.

Call the mParticle SDK `checkForDeferredDeepLinkWithCompletionHandler:` method to retrieve the respective information.

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKitDidBecomeActive:)
                                                 name:mParticleKitDidBecomeActiveNotification
                                               object:nil];

    [[MParticle sharedInstance] startWithKey:@"<<Your app key>>"
                                      secret:@"<<Your app secret>>"];

    return YES;
}

- (void)handleKitDidBecomeActive:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *kitNumber = userInfo[mParticleKitInstanceKey];

    if ([kitNumber isEqualToNumber:@(MPKitInstanceBranchMetrics)]) {
        [[MParticle sharedInstance] checkForDeferredDeepLinkWithCompletionHandler:^(NSDictionary * _Nullable params, NSError * _Nullable error) {
            if (params) {
                NSLog(@"params: %@", params);
            }
        }];
    }
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    [[MParticle sharedInstance] checkForDeferredDeepLinkWithCompletionHandler:^(NSDictionary * _Nullable linkInfo, NSError * _Nullable error) {
        NSLog(@"linkInfo: %@", linkInfo);
    }];

    return YES;
}
```

## Support

Questions? Give us a shout at <support@mparticle.com>


## License

This mParticle Apple Kit is available under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0). See the LICENSE file for more info.
