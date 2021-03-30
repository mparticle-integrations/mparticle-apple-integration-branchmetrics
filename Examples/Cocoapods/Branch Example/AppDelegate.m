//
//  AppDelegate.m
//  mParticle Branch Example
//

#import "AppDelegate.h"
@import mParticle_Apple_SDK;
@import Branch;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[Branch getInstance] enableLogging];
    
    MParticleOptions *options = [MParticleOptions optionsWithKey:@"REPLACE ME" secret:@"REPLACE ME"];
    // This block lives forever - it will be invoke whenever there is a NEW link or attribution result
    // this is essentially identical to the Branch iOS SDK's "DeepLinkHandler", that you can pass into
    // the Branch SDK's initSessionWithLaunchOptions method.
    //
    // The MPAttributionResult object is a wrapper around the NSDictionary that the Branch SDK returns,
    // which is documented here: https://github.com/BranchMetrics/ios-branch-deep-linking#parameters-1
    options.onAttributionComplete = ^(MPAttributionResult * _Nullable attributionResult, NSError * _Nullable error) {
        
        //
        // A few typical scenarios where this block would be invoked:
        //
        // (1) Base case:
        //     - User does not tap on a link, and then opens the app (either after a fresh install or not)
        //     - This block will be invoked with Branch Metrics' response indicating that this user did not tap on a link.
        //
        // (2) Deferred deep link:
        //     - User without the app installed taps on a link
        //     - User is redirected from Branch Metrics to the App Store and installs the app
        //     - User opens the app
        //     - This block will be invoked with Branch Metrics' response containing the details of the link
        //
        // (3) Deep link with app installed:
        //     - User with the app already installed taps on a link
        //     - Application opens via openUrl/continueUserActivity, mParticle forwards launch options etc to Branch
        //     - This block will be invoked with Branch Metrics' response containing the details of the link
        //
        // If the user navigates away from the app without killing it, this block could be invoked several times:
        // once for the initial launch, and then again each time the user taps on a link to re-open the app.
        
        if (!error) {
            if ([attributionResult.kitCode integerValue] == MPKitInstanceBranchMetrics) {
                if (attributionResult.linkInfo) {
                    //Insert custom logic to inspect the link information and route the user/customize the experience.
                    NSLog(@"params: %@", attributionResult.linkInfo.description);
                }
            }
        }
    };
    
    //The default of the proxyAppDelegate property is YES, which allows the mParticle SDK
    //to automatically detect methods such as continueUserActivity, and forward those methods
    //to the Branch SDK. If you choose to disable the mParticle SDK proxy, you must manually
    //forward the methods to the SDK.
    // See the docs here for more information:
    // http://docs.mparticle.com/developers/sdk/ios/initialize-the-sdk#appdelegate-proxy
    //options.proxyAppDelegate = NO;
    
    [[MParticle sharedInstance] startWithOptions:options];
    
    //You can also query for the latest deep link information at any time
    //This is identical to the Branch SDK's getLatestReferringParams API.
    //Note: this will return nil if there are no results yet. The asynchronous block pattern above should generally be preferred.
    NSDictionary<NSNumber *, MPAttributionResult *> *latestInfo = [[MParticle sharedInstance] attributionInfo];
    MPAttributionResult *latestResult = [latestInfo objectForKey:[NSNumber numberWithInt:MPKitInstanceBranchMetrics]];
    if (latestResult.linkInfo) {
        //Insert custom logic to inspect the link information and route the user/customize the experience.
        NSLog(@"params: %@", latestResult.linkInfo.description);
    }
    return YES;
}

@end
