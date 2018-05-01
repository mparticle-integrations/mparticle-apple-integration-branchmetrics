//
//  MPKitBranchMetrics.h
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

#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
#import <mParticle_Apple_SDK/mParticle.h>
#else
#import "mParticle.h"
#endif

extern void MPKitBranchMetricsLoadClass(void)
    __attribute__((constructor));

@interface MPKitBranchMetrics : NSObject <MPKitProtocol>

// mParticle version 7 start:
- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary*_Nonnull)configuration;

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, strong, nonnull) NSDictionary *launchOptions;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;
@property (nonatomic, strong, nullable, readonly) id providerKitInstance;
@property (nonatomic, strong, nullable) MPKitAPI *kitApi;
@end
