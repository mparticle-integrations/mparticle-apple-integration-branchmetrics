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
#import <Branch/Branch.h>
#if TARGET_OS_IOS == 1 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#import <UserNotifications/UNUserNotificationCenter.h>
#endif

__attribute__((constructor))
void MPKitBranchMetricsLoadClass(void) {
    // Empty function to force the class to load.
    // NSLog(@"MPKitBranchMetricsLoadClass().");
}

@interface MPEvent (Branch)
- (MPMessageType) messageType;
@end

NSString *const ekBMAppKey = @"branchKey";
NSString *const ekBMAForwardScreenViews = @"forwardScreenViews";
NSString *const ekBMAEnableAppleSearchAds = @"enableAppleSearchAds";

#pragma mark - MPKitBranchMetrics

@interface MPKitBranchMetrics() {
    NSArray<NSString*>*_branchEventTypes;
    NSArray<NSString*>*_branchEventActions;
    NSSet<NSString*>*_branchCategories;
}

+ (nonnull NSNumber *)kitCode;

- (instancetype _Nonnull) init NS_DESIGNATED_INITIALIZER;

// Version 7 Start:
- (MPKitExecStatus*_Nonnull)didFinishLaunchingWithConfiguration:(nonnull NSDictionary *)configuration;

- (void)start;

- (MPKitExecStatus*_Nonnull)continueUserActivity:(nonnull NSUserActivity *)userActivity
    restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler;

- (MPKitExecStatus*_Nonnull)openURL:(nonnull NSURL *)url
                            options:(nullable NSDictionary<NSString *, id> *)options;

- (MPKitExecStatus*_Nonnull)openURL:(nonnull NSURL *)url
                  sourceApplication:(nullable NSString *)sourceApplication
                         annotation:(nullable id)annotation;

- (MPKitExecStatus*_Nonnull)receivedUserNotification:(nonnull NSDictionary *)userInfo;
- (MPKitExecStatus*_Nonnull)logCommerceEvent:(nonnull MPCommerceEvent *)commerceEvent;
- (MPKitExecStatus*_Nonnull)logEvent:(nonnull MPEvent *)event;
- (MPKitExecStatus*_Nonnull)setKitAttribute:(nonnull NSString *)key value:(nullable id)value;
- (MPKitExecStatus*_Nonnull)setOptOut:(BOOL)optOut;

@property (assign) BOOL forwardScreenViews;
@property (assign) BOOL enableAppleSearchAds;
@property (strong, nullable) Branch *branchInstance;
@property (readwrite) BOOL started;
@end

#pragma mark - MPKitBranchMetrics

@implementation MPKitBranchMetrics

+ (NSNumber *)kitCode {
    return @80;
}

+ (void)load {
    MPKitRegister *kitRegister =
        [[MPKitRegister alloc] initWithName:@"BranchMetrics"
            className:@"MPKitBranchMetrics"];
    [MParticle registerExtension:kitRegister];
}

static BOOL _appleSearchAdsDebugMode;

+ (void) setAppleSearchAdsDebugMode:(BOOL)appleSearchAdsDebugMode_ {
    _appleSearchAdsDebugMode = appleSearchAdsDebugMode_;
}

+ (BOOL) appleSearchAdsDebugMode {
    return _appleSearchAdsDebugMode;
}

- (MPKitExecStatus*) execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

#pragma mark - MPKitInstanceProtocol Lifecycle Methods

- (instancetype _Nonnull) init {
    self = [super init];
    self.configuration = @{};
    self.launchOptions = @{};
    return self;
}

- (MPKitExecStatus*_Nonnull)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    self.configuration = configuration;
    NSString *branchKey = configuration[ekBMAppKey];
    if (!branchKey) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
    self.forwardScreenViews = [configuration[ekBMAForwardScreenViews] boolValue];
    self.enableAppleSearchAds = [configuration[ekBMAEnableAppleSearchAds] boolValue];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (id const)providerKitInstance {
    return [self started] ? self.branchInstance : nil;
}

- (void)start {
    static dispatch_once_t branchMetricsPredicate = 0;
    dispatch_once(&branchMetricsPredicate, ^{
        NSString *branchKey = [self.configuration[ekBMAppKey] copy];
        self.branchInstance = [Branch getInstance:branchKey];
        if (self.enableAppleSearchAds) [self.branchInstance delayInitToCheckForSearchAds];
        if (self.class.appleSearchAdsDebugMode) [self.branchInstance setAppleSearchAdsDebugMode];
        [self.branchInstance initSessionWithLaunchOptions:self.launchOptions
            isReferrable:YES
            andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
            MPAttributionResult *attributionResult = [[MPAttributionResult alloc] init];
            if (error) {
                [self.kitApi onAttributionCompleteWithResult:attributionResult error:error];
                return;
            }
            attributionResult.linkInfo = params;
            [self->_kitApi onAttributionCompleteWithResult:attributionResult error:nil];
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.branchInstance) {
                self.started = YES;
            }

            NSMutableDictionary *userInfo = [@{
                mParticleKitInstanceKey: [[self class] kitCode],
                @"branchKey": branchKey
            } mutableCopy];

            [[NSNotificationCenter defaultCenter]
                postNotificationName:mParticleKitDidBecomeActiveNotification
                object:nil
                userInfo:userInfo];
        });
    });
}

#pragma mark - MPKitInstanceProtocol Methods

- (MPKitExecStatus*_Nonnull)setKitAttribute:(nonnull NSString *)key value:(nullable id)value {
    [self.kitApi logError:@"Unrecognized key attibute '%@'.", key];
    return [self execStatus:MPKitReturnCodeUnavailable];
}

- (MPKitExecStatus*_Nonnull)setOptOut:(BOOL)optOut {
    [Branch setTrackingDisabled:optOut];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)setUserIdentity:(NSString *)identityString
                        identityType:(MPUserIdentity)identityType {
    if (identityType == MPUserIdentityCustomerId && identityString.length > 0) {
        [self.branchInstance setIdentity:identityString];
        return [self execStatus:MPKitReturnCodeSuccess];
    } else {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
}

- (MPKitExecStatus*_Nonnull)logout {
    [self.branchInstance logout];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logEvent:(MPEvent *)event {
    [[self branchEventWithEvent:event] logEvent];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)logCommerceEvent:(nonnull MPCommerceEvent *)commerceEvent {
    [[self branchEventWithCommerceEvent:commerceEvent] logEvent];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)logScreen:(MPEvent *)mpEvent {
    if (!self.forwardScreenViews) {
        return [self execStatus:MPKitReturnCodeUnavailable];
    }
    [[self branchEventWithStandardEvent:mpEvent] logEvent];
    return [self execStatus:MPKitReturnCodeSuccess];
}

#pragma mark - Deep Linking

- (MPKitExecStatus*_Nonnull)continueUserActivity:(nonnull NSUserActivity *)userActivity
    restorationHandler:(void(^ _Nonnull)(NSArray * _Nullable restorableObjects))restorationHandler {
    [self.branchInstance continueUserActivity:userActivity];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url
                             options:(nullable NSDictionary<NSString *, id> *)options {
    [self.branchInstance handleDeepLink:url];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)openURL:(nonnull NSURL *)url
                   sourceApplication:(nullable NSString *)sourceApplication
                          annotation:(nullable id)annotation {
    [self.branchInstance handleDeepLink:url];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
    [self.branchInstance handlePushNotification:userInfo];
    return [self execStatus:MPKitReturnCodeSuccess];
}

#if TARGET_OS_IOS == 1 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"

- (nonnull MPKitExecStatus *)userNotificationCenter:(nonnull UNUserNotificationCenter *)center
                            willPresentNotification:(nonnull UNNotification *)notification {
    [self.branchInstance handlePushNotification:notification.request.content.userInfo];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)userNotificationCenter:(nonnull UNUserNotificationCenter *)center
                     didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response {
    [self.branchInstance handlePushNotification:response.notification.request.content.userInfo];
    return [self execStatus:MPKitReturnCodeSuccess];
}

#pragma clang diagnostic pop
#endif

#pragma mark - Event Transformation

#define addStringField(field, name) { \
    NSString *value = dictionary[@#name]; \
    if (value) { \
        if ([value isKindOfClass:NSString.class]) \
            field = value; \
        else \
            field = [value description]; \
        dictionary[@#name] = nil; \
    } \
}

#define addDecimalField(field, name) { \
    NSString *value = dictionary[@#name]; \
    if (value) { \
        if (![value isKindOfClass:NSString.class]) \
            value = [value description]; \
        field = [NSDecimalNumber decimalNumberWithString:value]; \
        dictionary[@#name] = nil; \
    } \
}

#define addDoubleField(field, name) { \
    NSNumber *value = dictionary[@#name]; \
    if ([value respondsToSelector:@selector(doubleValue)]) { \
        field = [value doubleValue]; \
        dictionary[@#name] = nil; \
    } \
}

- (NSSet<NSString*>*) branchCategories {
    @synchronized(self) {
        if (!_branchCategories) {
            _branchCategories = [NSSet setWithArray:BNCProductCategoryAllCategories()];
        }
    return _branchCategories;
    }
}

- (BranchUniversalObject*) branchUniversalObjectFromDictionary:(NSMutableDictionary*)dictionary {
    NSInteger startCount = dictionary.count;
    BranchUniversalObject *object = [[BranchUniversalObject alloc] init];
    
    addStringField(object.canonicalIdentifier, Id);
    addStringField(object.title, Name);
    object.contentMetadata.productName = object.title;
    addStringField(object.contentMetadata.productBrand, Brand);
    addStringField(object.contentMetadata.productVariant, Variant);
    NSString *category = dictionary[@"Category"];
    if ([category isKindOfClass:NSString.class] && category.length) {
        if ([self.branchCategories containsObject:category])
            object.contentMetadata.productCategory = category;
        else
            object.contentMetadata.customMetadata[@"product_category"] = category;
        dictionary[@"Category"] = nil;
    }
    addDecimalField(object.contentMetadata.price, Item Price);
    addDoubleField(object.contentMetadata.quantity, Quantity);
    addStringField(object.contentMetadata.currency, Currency Code);

    return (dictionary.count == startCount) ? nil : object;
}

- (NSString*) stringFromObject:(id<NSObject>)object {
    if (object == nil) return nil;
    if ([object isKindOfClass:NSString.class]) {
        return (NSString*) object;
    } else
    if ([object respondsToSelector:@selector(stringValue)]) {
        return [(id)object stringValue];
    }
    return [object description];
}

- (NSMutableDictionary*) stringDictionaryFromDictionary:(NSDictionary*)dictionary_ {
    if (dictionary_ == nil) return nil;
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    for(id<NSObject> key in dictionary_.keyEnumerator) {
        NSString* stringValue = [self stringFromObject:dictionary_[key]];
        NSString* stringKey = [self stringFromObject:key];
        if (stringKey) dictionary[stringKey] = stringValue;
    }
    return dictionary;
}

- (BranchEvent*) branchEventWithEvent:(MPEvent*)mpEvent {
    if ([mpEvent.name hasPrefix:@"eCommerce"] && [mpEvent.info[@"an"] length] > 0)
        return [self branchEventWithPromotionEvent:mpEvent];
    else
        return [self branchEventWithStandardEvent:mpEvent];
}

- (BranchEvent*) branchEventWithPromotionEvent:(MPEvent*)mpEvent {
    NSString *eventName = nil;
    NSString *actionName = mpEvent.info[@"an"];
    if ([actionName isEqualToString:@"view"])
        eventName = @"VIEW_PROMOTION";
    else
    if ([actionName isEqualToString:@"click"])
        eventName = @"CLICK_PROMOTION";
    else
    if (actionName.length > 0)
        eventName = actionName;
    else
        eventName = @"PROMOTION";
    NSArray *productList = mpEvent.info[@"pl"];
    NSDictionary *product = nil;
    if ([productList isKindOfClass:NSArray.class] && productList.count > 0)
        product = productList[0];

    BranchEvent *event = [BranchEvent customEventWithName:eventName];
    event.eventDescription = mpEvent.name;
    event.customData = [self stringDictionaryFromDictionary:product];
    [event.customData addEntriesFromDictionary:[self stringDictionaryFromDictionary:mpEvent.customFlags]];

    return event;
}

- (BranchEvent*) branchEventWithStandardEvent:(MPEvent*)mpEvent {
    NSArray *actionNames = @[
        @"add_to_cart",
        @"remove_from_cart",
        @"add_to_wishlist",
        @"remove_from_wishlist",
        @"checkout",
        @"checkout_option",
        @"click",
        @"view_detail",
        @"purchase",
        @"refund"
    ];
    NSString *eventName = nil;
    if (mpEvent.messageType == MPMessageTypeScreenView) {
        eventName = BranchStandardEventViewItem;
    } else
    if (mpEvent.messageType == MPMessageTypeEvent) {
        eventName = mpEvent.name;
        if (!eventName.length)
            eventName = mpEvent.typeName;
        if (!eventName.length)
            eventName = [NSString stringWithFormat:@"mParticle event type %ld", (long)mpEvent.type];
    } else {
        int i = 0;
        for (NSString *action in actionNames) {
            NSRange range = [mpEvent.name rangeOfString:action options:NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch];
            if (range.location != NSNotFound) {
                eventName = [self branchEventNameFromEventAction:i];
                break;
            }
            ++i;
        }
    }
    if (!eventName) eventName = mpEvent.name;
    if (!eventName) eventName = @"OTHER_EVENT";
    BranchEvent *event = [BranchEvent customEventWithName:eventName];
    event.eventDescription = mpEvent.name;
    NSMutableDictionary *dictionary = [mpEvent.info mutableCopy];
    BranchUniversalObject *object = [self branchUniversalObjectFromDictionary:dictionary];
    if (object) [event.contentItems addObject:object];

    addStringField(event.transactionID, Transaction Id);
    addStringField(event.currency, Currency);
    addDecimalField(event.revenue, Total Product Amount);
    addDecimalField(event.shipping, Shipping Amount);
    addDecimalField(event.tax, Tax Amount);
    addStringField(event.coupon, Coupon Code);
    addStringField(event.affiliation, Affiliation);
    addStringField(event.searchQuery, Search);
    [event.customData addEntriesFromDictionary:[self stringDictionaryFromDictionary:mpEvent.customFlags]];
    [event.customData addEntriesFromDictionary:[self stringDictionaryFromDictionary:dictionary]];
    if (mpEvent.category.length) event.customData[@"category"] = mpEvent.category;

    return event;
}

- (BranchUniversalObject*) branchUniversalObjectFromProduct:(MPProduct*)product {
    BranchUniversalObject *buo = [BranchUniversalObject new];
    buo.contentMetadata.productBrand = product.brand;
    if (product.category.length) {
        if ([self.branchCategories containsObject:product.category])
            buo.contentMetadata.productCategory = product.category;
        else
            buo.contentMetadata.customMetadata[@"product_category"] = product.category;
    }
    buo.contentMetadata.customMetadata[@"coupon"] = product.couponCode;
    buo.contentMetadata.productName = product.name;
    buo.contentMetadata.price = [self decimal:product.price];
    buo.contentMetadata.sku = product.sku;
    buo.contentMetadata.productVariant = product.variant;
    buo.contentMetadata.customMetadata[@"position"] =
        [NSString stringWithFormat:@"%lu", (unsigned long) product.position];
    buo.contentMetadata.quantity = [product.quantity doubleValue];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (product.totalAmount > 0.0)
        buo.contentMetadata.customMetadata[@"amount"] =
            [NSString stringWithFormat:@"%1.2f", product.totalAmount];
    #pragma clang diagnostic pop
    [buo.contentMetadata.customMetadata addEntriesFromDictionary:
        [self stringDictionaryFromDictionary:product.userDefinedAttributes]];
    return buo;
}

- (NSDecimalNumber*) decimal:(NSNumber*)number {
    return [NSDecimalNumber decimalNumberWithDecimal:number.decimalValue];
}

- (NSString*) branchEventNameFromEventAction:(MPCommerceEventAction)action {
    /*
    typedef NS_ENUM(NSUInteger, MPCommerceEventAction) {
        MPCommerceEventActionAddToCart = 0,
        MPCommerceEventActionRemoveFromCart,
        MPCommerceEventActionAddToWishList,
        MPCommerceEventActionRemoveFromWishlist,
        MPCommerceEventActionCheckout,
        MPCommerceEventActionCheckoutOptions,
        MPCommerceEventActionClick,
        MPCommerceEventActionViewDetail,
        MPCommerceEventActionPurchase,
        MPCommerceEventActionRefund
    };
    */
    @synchronized(self) {
        if (!_branchEventActions) {
            _branchEventActions = @[
                BranchStandardEventAddToCart,
                @"REMOVE_FROM_CART",
                BranchStandardEventAddToWishlist,
                @"REMOVE_FROM_WISHLIST",
                BranchStandardEventInitiatePurchase,
                BranchStandardEventInitiatePurchase,
                BranchStandardEventViewItem,
                BranchStandardEventViewItem,
                BranchStandardEventPurchase,
                @"REFUND",
            ];
        }
    }
    if (action < _branchEventActions.count) return _branchEventActions[action];
    return nil;
}

- (BranchEvent*) branchEventWithCommerceEvent:(MPCommerceEvent*)mpEvent {
    NSString *eventName = [self branchEventNameFromEventAction:mpEvent.action];
    if (!eventName)
        eventName = [NSString stringWithFormat:@"mParticle commerce event %ld", (long) mpEvent.action];
    BranchEvent *event = [BranchEvent customEventWithName:eventName];
    for (MPProduct *product in mpEvent.products) {
        BranchUniversalObject *obj = [self branchUniversalObjectFromProduct:product];
        if (obj) {
            obj.contentMetadata.currency = mpEvent.currency;
            obj.contentMetadata.customMetadata[@"product_list_name"] = mpEvent.productListName;
            obj.contentMetadata.customMetadata[@"product_list_source"] = mpEvent.productListSource;
            [event.contentItems addObject:obj];
        }
    }
    for (NSString* impression in mpEvent.impressions.keyEnumerator) {
        NSSet *set = mpEvent.impressions[impression];
        for (MPProduct *product in set) {
            BranchUniversalObject *obj = [self branchUniversalObjectFromProduct:product];
            if (obj) {
                obj.contentMetadata.currency = mpEvent.currency;
                obj.contentMetadata.customMetadata[@"impression"] = impression;
                [event.contentItems addObject:obj];
            }
        }
    }
    for (MPPromotion *promo in mpEvent.promotionContainer.promotions) {
        BranchUniversalObject *obj = [BranchUniversalObject new];
        obj.canonicalIdentifier = promo.promotionId;
        obj.title = promo.name;
        obj.contentMetadata.customMetadata[@"position"] = promo.position;
        obj.contentMetadata.customMetadata[@"creative"] = promo.creative;
        [event.contentItems addObject:obj];
    }
    event.customData[@"product_list_name"] = mpEvent.productListName;
    event.customData[@"product_list_source"] = mpEvent.productListSource;
    event.customData[@"screen_name"] = mpEvent.screenName;
    event.customData[@"checkout_options"] = mpEvent.checkoutOptions;
    event.currency = mpEvent.currency;
    event.affiliation = mpEvent.transactionAttributes.affiliation;
    event.coupon = mpEvent.transactionAttributes.couponCode;
    event.shipping = [self decimal:mpEvent.transactionAttributes.shipping];
    event.tax = [self decimal:mpEvent.transactionAttributes.tax];
    event.revenue = [self decimal:mpEvent.transactionAttributes.revenue];
    event.transactionID = mpEvent.transactionAttributes.transactionId;
    NSInteger checkoutStep = mpEvent.checkoutStep;
    if (checkoutStep >= 0 && checkoutStep < (NSInteger) 0x7fffffff) {
        event.customData[@"checkout_step"] =
            [NSString stringWithFormat:@"%ld", (long) mpEvent.checkoutStep];
    }
    event.customData[@"non_interactive"] = mpEvent.nonInteractive ? @"true" : @"false";
    return event;
}

@end
