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
#import "MPEvent.h"
#import "mParticle.h"
#import "MPKitRegister.h"
#import "Branch.h"

NSString *const ekBMAppKey = @"branchKey";
NSString *const ekBMAForwardScreenViews = @"forwardScreenViews";

@interface MPKitBranchMetrics() {
    Branch *branchInstance;
    BOOL forwardScreenViews;
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
    NSAssert(configuration != nil, @"Required parameter. It cannot be nil.");
    self = [super init];
    if (!self) {
        return nil;
    }

    NSString *branchKey = configuration[ekBMAppKey];
    branchInstance = nil;

    BOOL validConfiguration = branchKey != nil && (NSNull *)branchKey != [NSNull null] && (branchKey.length > 0);
    if (!validConfiguration) {
        return nil;
    }

    forwardScreenViews = [configuration[ekBMAForwardScreenViews] boolValue];
    _configuration = configuration;
    _started = startImmediately;

    if (startImmediately) {
        [self start];
    }

    return self;
}

- (id const)kitInstance {
    return [self started] ? branchInstance : nil;
}

- (void)start {
    static dispatch_once_t branchMetricsPredicate;

    dispatch_once(&branchMetricsPredicate, ^{
        NSString *branchKey = [self.configuration[ekBMAppKey] copy];
        branchInstance = [Branch getInstance:branchKey];

        [branchInstance initSessionWithLaunchOptions:self.launchOptions isReferrable:YES andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
            _started = YES;

            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableDictionary *userInfo = [@{mParticleKitInstanceKey:[[self class] kitCode],
                                                   mParticleEmbeddedSDKInstanceKey:[[self class] kitCode],
                                                   @"branchKey":branchKey} mutableCopy];

                if (params && params.count > 0) {
                    userInfo[@"params"] = params;
                }

                if (error) {
                    userInfo[@"error"] = error;
                }

                [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                    object:nil
                                                                  userInfo:userInfo];

                [[NSNotificationCenter defaultCenter] postNotificationName:mParticleEmbeddedSDKDidBecomeActiveNotification
                                                                    object:nil
                                                                  userInfo:userInfo];
            });
        }];
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

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url sourceApplication:(nonnull NSString *)sourceApplication annotation:(nullable id)annotation {
    [branchInstance handleDeepLink:url];

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

@end
