//
//  MPKitBranchMetrics.m
//
//  Copyright 2016 mParticle, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "MPKitBranchMetrics.h"
#if defined(COCOAPODS) || defined(MPARTICLE_MANUAL_INSTALL)
    #import <Branch/Branch.h>
#else
    #import <BranchSDK/Branch.h>
#endif

NSString *const ekBMAppKey = @"branchKey";
NSString *const ekBMAForwardScreenViews = @"forwardScreenViews";

@interface MPKitBranchMetrics() {
    Branch *branchInstance;
    BOOL forwardScreenViews;
    NSDictionary *temporaryParams;
    NSError *temporaryError;
    void (^completionHandlerCopy)(NSDictionary<NSString *, NSString *> *, NSError *);
}

@end

@implementation MPKitBranchMetrics

+ (NSNumber *)kitCode {
    return @80;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"BranchMetrics" className:@"MPKitBranchMetrics" startImmediately:NO];
    [MParticle registerExtension:kitRegister];
}

#pragma mark MPKitInstanceProtocol methods
- (instancetype)initWithConfiguration:(NSDictionary *)configuration startImmediately:(BOOL)startImmediately {
    self = [super init];
    NSString *branchKey = configuration[ekBMAppKey];
    if (!self || !branchKey) {
        return nil;
    }

    branchInstance = nil;
    forwardScreenViews = [configuration[ekBMAForwardScreenViews] boolValue];
    _configuration = configuration;
    _started = startImmediately;
    temporaryParams = nil;
    temporaryError = nil;

    if (startImmediately) {
        [self start];
    }

    return self;
}

- (id const)providerKitInstance {
    return [self started] ? branchInstance : nil;
}

- (void)start {
    static dispatch_once_t branchMetricsPredicate;

    dispatch_once(&branchMetricsPredicate, ^{
        NSString *branchKey = [self.configuration[ekBMAppKey] copy];
        branchInstance = [Branch getInstance:branchKey];

        [branchInstance initSessionWithLaunchOptions:self.launchOptions isReferrable:YES andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
            temporaryParams = [params copy];
            temporaryError = [error copy];

            if (completionHandlerCopy) {
                completionHandlerCopy(params, error);
                temporaryParams = nil;
                temporaryError = nil;
            }
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (branchInstance) {
                _started = YES;
            }

            NSMutableDictionary *userInfo = [@{mParticleKitInstanceKey:[[self class] kitCode],
                                               @"branchKey":branchKey} mutableCopy];

            if (temporaryParams && temporaryParams.count > 0) {
                userInfo[@"params"] = temporaryParams;
            }

            if (temporaryError) {
                userInfo[@"error"] = temporaryError;
            }

            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

- (nonnull MPKitExecStatus *)continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
    [branchInstance continueUserActivity:userActivity];

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBranchMetrics) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)logout {
    [branchInstance logout];

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBranchMetrics) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)logEvent:(MPEvent *)event {
    if (event.info.count > 0) {
        [branchInstance userCompletedAction:event.name withState:event.info];
    } else {
        [branchInstance userCompletedAction:event.name];
    }

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBranchMetrics) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    MPKitExecStatus *execStatus;

    if (!forwardScreenViews) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBranchMetrics) returnCode:MPKitReturnCodeUnavailable];
        return execStatus;
    }

    NSString *actionName = [NSString stringWithFormat:@"Viewed %@", event.name];

    if (event.info.count > 0) {
        [branchInstance userCompletedAction:actionName withState:event.info];
    } else {
        [branchInstance userCompletedAction:actionName];
    }

    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBranchMetrics) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url options:(nullable NSDictionary<NSString *, id> *)options {
    [branchInstance handleDeepLink:url];

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBranchMetrics) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nullable id)annotation {
    [branchInstance handleDeepLink:url];

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBranchMetrics) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
    [branchInstance handlePushNotification:userInfo];

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBranchMetrics) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString identityType:(MPUserIdentity)identityType {
    MPKitExecStatus *execStatus;

    if (identityType != MPUserIdentityCustomerId || identityString.length == 0) {
        execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBranchMetrics) returnCode:MPKitReturnCodeRequirementsNotMet];
        return execStatus;
    }

    [branchInstance setIdentity:identityString];

    execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBranchMetrics) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

- (MPKitExecStatus *)checkForDeferredDeepLinkWithCompletionHandler:(void(^)(NSDictionary<NSString *, NSString *> *linkInfo, NSError *error))completionHandler {
    completionHandlerCopy = [completionHandler copy];
    if (_started && (temporaryParams || temporaryError)) {
        completionHandler(temporaryParams, temporaryError);
        temporaryParams = nil;
        temporaryError = nil;
    }

    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBranchMetrics) returnCode:MPKitReturnCodeSuccess];
    return execStatus;
}

@end
