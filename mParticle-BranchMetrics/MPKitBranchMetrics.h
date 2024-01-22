#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
    #import <mParticle_Apple_SDK/mParticle.h>
    #import <mParticle_Apple_SDK/mParticle_Apple_SDK-Swift.h>
#elif defined(__has_include) && __has_include(<mParticle_Apple_SDK_NoLocation/mParticle.h>)
    #import <mParticle_Apple_SDK_NoLocation/mParticle.h>
    #import <mParticle_Apple_SDK_NoLocation/mParticle_Apple_SDK-Swift.h>
#else
    #import "mParticle.h"
    #import "mParticle_Apple_SDK-Swift.h"
#endif

extern void MPKitBranchMetricsLoadClass(void)
    __attribute__((constructor));

@interface MPKitBranchMetrics : NSObject <MPKitProtocol>

// mParticle version 7 start:
- (MPKitExecStatus *_Nonnull)didFinishLaunchingWithConfiguration:(NSDictionary*_Nonnull)configuration;

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, strong, nonnull) NSDictionary *launchOptions;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;
@property (nonatomic, strong, nullable, readonly) id providerKitInstance;
@property (nonatomic, strong, nullable) MPKitAPI *kitApi;
@end
