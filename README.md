## Branch Kit Integration

This repository contains the [Branch](https://branch.io) integration for the [mParticle Apple SDK](https://github.com/mParticle/mparticle-apple-sdk).

### Adding the integration

1. Add the kit dependency to your app's Podfile or Cartfile:

    ```
    pod 'mParticle-BranchMetrics', '~> 7.0'
    ```

    OR

    ```
    github 'mparticle-integrations/mparticle-apple-integration-branchmetrics' ~> 7.0
    ```

2. Follow the mParticle iOS SDK [quick-start](https://github.com/mParticle/mparticle-apple-sdk), then rebuild and launch your app, and verify that you see `"Included kits: { BranchMetrics }"` in your Xcode console 

> (This requires your mParticle log level to be at least Debug)

3. Reference mParticle's integration docs below to enable the integration.

## Deep-linking

Set the property `onAttributionComplete:` on `MParticleOptions` when initializing the mParticle SDK. A copy of your block will be invoked to provide the respective information:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    MParticleOptions *options = [MParticleOptions optionsWithKey:@"<<Your app key>>" secret:@"<<Your app secret>>"];
    options.onAttributionComplete = ^void (MPAttributionResult *_Nullable attributionResult, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Attribution fetching for kitCode=%@ failed with error=%@", error.userInfo[mParticleKitInstanceKey], error);
            return;
        }

        NSLog(@"Attribution fetching for kitCode=%@ completed with linkInfo: %@", attributionResult.kitCode, attributionResult.linkInfo);

    }
    [[MParticle sharedInstance] startWithOptions:options];

    return YES;
}
```

### Documentation

[Branch integration](https://docs.mparticle.com/integrations/branch-metrics/event/)

### License

[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
