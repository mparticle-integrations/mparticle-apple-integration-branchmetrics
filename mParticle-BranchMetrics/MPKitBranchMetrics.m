#import "MPKitBranchMetrics.h"
#if defined(__has_include) && __has_include(<BranchSDK/Branch.h>)
    #import <BranchSDK/Branch.h>
#else
    #import "Branch.h"
#endif
#if TARGET_OS_IOS == 1 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#import <UserNotifications/UNUserNotificationCenter.h>
#endif
#import "mParticle_BranchMetrics.h"
#if defined(__has_include) && __has_include(<BranchSDK/BranchEvent.h>)
    #import <BranchSDK/BranchEvent.h>
#else
    #import "BranchEvent.h"
#endif

__attribute__((constructor))
void MPKitBranchMetricsLoadClass(void) {
    // Empty function to force the class to load.
    // NSLog(@"MPKitBranchMetricsLoadClass().");
}

@interface MPEvent (Branch)
- (MPMessageType) messageType;
@end

NSString *const MPKitBranchMetricsVersionNumber = @"8.1.0";
NSString *const ekBMAppKey = @"branchKey";
NSString *const ekBMAForwardScreenViews = @"forwardScreenViews";
NSString *const userIdentificationType = @"userIdentificationType";

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
- (MPKitExecStatus*_Nonnull)logBaseEvent:(nonnull MPBaseEvent *)event;
- (MPKitExecStatus*_Nonnull)setKitAttribute:(nonnull NSString *)key value:(nullable id)value;
- (MPKitExecStatus*_Nonnull)setOptOut:(BOOL)optOut;

@property (assign) BOOL forwardScreenViews;
@property (strong, nullable) Branch *branchInstance;
@property (readwrite) BOOL started;
@property (readwrite) BOOL isMpidIdentityType;
@property (readwrite) MPIdentity identityType;
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
    [self updateIdentityType:configuration];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (void)updateIdentityType:(NSDictionary *)configuration {
        NSString *identityString = configuration[userIdentificationType];
        if (identityString != nil) {
            if ([identityString isEqualToString:@"MPID"]) {
                _isMpidIdentityType = true;
            } else if ([identityString isEqualToString:@"CustomerId"]){
                _identityType = MPIdentityCustomerId;
            } else if ([identityString isEqualToString:@"Email"]){
                _identityType = MPIdentityEmail;
            } else if ([identityString isEqualToString:@"Other"]){
                _identityType = MPIdentityOther;
            } else if ([identityString isEqualToString:@"Other2"]){
                _identityType = MPIdentityOther2;
            } else if ([identityString isEqualToString:@"Other3"]){
                _identityType = MPIdentityOther3;
            } else if ([identityString isEqualToString:@"Other4"]){
                _identityType = MPIdentityOther4;
            } else if ([identityString isEqualToString:@"Other5"]){
                _identityType = MPIdentityOther5;
            } else if ([identityString isEqualToString:@"Other6"]){
                _identityType = MPIdentityOther6;
            } else if ([identityString isEqualToString:@"Other7"]){
                _identityType = MPIdentityOther7;
            } else if ([identityString isEqualToString:@"Other8"]){
                _identityType = MPIdentityOther8;
            } else if ([identityString isEqualToString:@"Other9"]){
                _identityType = MPIdentityOther9;
            } else if ([identityString isEqualToString:@"Other10"]){
                _identityType = MPIdentityOther10;
            } else if ([identityString isEqualToString:@"MobileNumber"]){
                _identityType = MPIdentityMobileNumber;
            } else if ([identityString isEqualToString:@"PhoneNumber2"]){
                _identityType = MPIdentityPhoneNumber2;
            } else if ([identityString isEqualToString:@"PhoneNumber3"]){
                _identityType = MPIdentityPhoneNumber3;
            } else {
                _identityType = MPIdentityEmail;
            }
        }
    }

- (id const)providerKitInstance {
    return [self started] ? self.branchInstance : nil;
}

- (void)start {
    static dispatch_once_t branchMetricsPredicate = 0;
    dispatch_once(&branchMetricsPredicate, ^{
        NSString *branchKey = [self.configuration[ekBMAppKey] copy];
        self.branchInstance = [Branch getInstance:branchKey];
        
        [self.branchInstance registerPluginName:@"mParticleKit" version:MPKitBranchMetricsVersionNumber];
                
        // iOS 15 Branch NativeLink™ support
        // https://help.branch.io/developers-hub/docs/ios-advanced-features#nativelink-deferred-deep-linking
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([self.branchInstance respondsToSelector:@selector(checkPasteboardOnInstall)]) {
            [self.branchInstance performSelector:@selector(checkPasteboardOnInstall)];
        }
        #pragma clang diagnostic pop
        
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

        // mParticle isn't calling back with the URL on startup fast enough or in the right order, so handle it here:
        NSURL*URL = self.launchOptions[UIApplicationLaunchOptionsURLKey];
        if (URL) [self.branchInstance handleDeepLinkWithNewSession:URL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.branchInstance) {
                self.started = YES;
            }
            
            NSMutableDictionary *userInfo = [@{
                mParticleKitInstanceKey: [[self class] kitCode],
                @"branchKey": (self.configuration[ekBMAppKey] != nil) ? self.configuration[ekBMAppKey] : @""
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
    NSLog(@"mParticle -> Branch Kit: Unrecognized key attribute '%@'.", key);
    
    return [self execStatus:MPKitReturnCodeUnavailable];
}

- (MPKitExecStatus*_Nonnull)setOptOut:(BOOL)optOut {
    [Branch setTrackingDisabled:optOut];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onIdentifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    [self updateUser:user];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request{
    [self updateUser:user];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onLogoutComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    [self updateUser:user];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onModifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    [self updateUser:user];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (void)updateUser:(FilteredMParticleUser *)user {
    if (_isMpidIdentityType) {
        [self.branchInstance setIdentity:user.userId.stringValue];
    } else if (_identityType != MPIdentityEmail) {
        NSString *mPIdentity = user.userIdentities[@(_identityType)];
        if (mPIdentity != nil) {
            [self.branchInstance setIdentity:mPIdentity];
        }
    }
}

- (MPKitExecStatus*_Nonnull)logout {
    [self.branchInstance logout];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)logBaseEvent:(nonnull MPBaseEvent *)event {
    if ([event isKindOfClass:[MPEvent class]]) {
        return [self routeEvent:(MPEvent *)event];
    } else if ([event isKindOfClass:[MPCommerceEvent class]]) {
        return [self routeCommerceEvent:(MPCommerceEvent *)event];
    } else {
        return [self execStatus:MPKitReturnCodeUnavailable];
    }
}

- (MPKitExecStatus *)routeEvent:(MPEvent *)mpEvent {
    [[self branchEventWithStandardEvent:mpEvent] logEvent];
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (nonnull MPKitExecStatus *)routeCommerceEvent:(nonnull MPCommerceEvent *)commerceEvent {
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

- (NSString*) branchEventNameFromEventType:(MPEventType)eventType {
    @synchronized (self) {
        if (!_branchEventTypes) {
            _branchEventTypes = @[
                BranchStandardEventAddToCart,       // MPEventTypeAddToCart = 10,
                @"REMOVE_FROM_CART",                // MPEventTypeRemoveFromCart = 11,
                BranchStandardEventInitiatePurchase,// MPEventTypeCheckout = 12,
                @"PURCHASE_OPTION",                 // MPEventTypeCheckoutOption = 13,
                @"CLICK_ITEM",                      // MPEventTypeClick = 14,
                BranchStandardEventViewItem,        // MPEventTypeViewDetail = 15,
                BranchStandardEventPurchase,        // MPEventTypePurchase = 16,
                @"REFUND",                          // MPEventTypeRefund = 17,
                @"VIEW_PROMOTION",                  // MPEventTypePromotionView = 18,
                @"CLICK_PROMOTION",                 // MPEventTypePromotionClick = 19,
                BranchStandardEventAddToWishlist,   // MPEventTypeAddToWishlist = 20,
                @"REMOVE_FROM_WISHLIST",            // MPEventTypeRemoveFromWishlist = 21,
                @"IMPRESSION"                       // MPEventTypeImpression = 22
            ];
        }
    }
    NSInteger index = (NSInteger) eventType - (NSInteger) MPEventTypeAddToCart;
    if (index < 0 || index >= _branchEventTypes.count) return nil;
    return _branchEventTypes[index];
}

- (BranchEvent*) branchEventWithStandardEvent:(MPEvent*)mpEvent {
    NSString *eventName = mpEvent.name;
    if (eventName.length == 0) return nil;
    
    BranchEvent *event = [BranchEvent customEventWithName:eventName];
    event.eventDescription = mpEvent.name;
    NSMutableDictionary *dictionary = [mpEvent.customAttributes mutableCopy];
    BranchUniversalObject *object = [self branchUniversalObjectFromDictionary:dictionary];
    if (object) {
        NSMutableArray<BranchUniversalObject*>* mutableCopy = [[NSMutableArray alloc] initWithArray:event.contentItems];
        [mutableCopy addObject:object];
        event.contentItems = mutableCopy;
    }

    NSMutableDictionary<NSString*, NSString*>* mutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:event.customData];
    [mutableDictionary addEntriesFromDictionary:[self stringDictionaryFromDictionary:dictionary]];
    if (mpEvent.category.length) mutableDictionary[@"category"] = mpEvent.category;
    event.customData = mutableDictionary;
    event.alias = mutableDictionary[@"customer_event_alias"];

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
                @"PURCHASE_OPTION",
                @"CLICK_ITEM",
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
    if (!eventName) eventName = [self branchEventNameFromEventType:mpEvent.type];
    if (!eventName) eventName = @"OTHER";
    BranchEvent *event = [BranchEvent customEventWithName:eventName];
    for (MPProduct *product in mpEvent.products) {
        BranchUniversalObject *obj = [self branchUniversalObjectFromProduct:product];
        if (obj) {
            obj.contentMetadata.currency = mpEvent.currency;
            obj.contentMetadata.customMetadata[@"product_list_name"] = mpEvent.productListName;
            obj.contentMetadata.customMetadata[@"product_list_source"] = mpEvent.productListSource;
            NSMutableArray<BranchUniversalObject*>* mutableCopy = [[NSMutableArray alloc] initWithArray:event.contentItems];
            [mutableCopy addObject:obj];
            event.contentItems = mutableCopy;
        }
    }
    for (NSString* impression in mpEvent.impressions.keyEnumerator) {
        NSSet *set = mpEvent.impressions[impression];
        for (MPProduct *product in set) {
            BranchUniversalObject *obj = [self branchUniversalObjectFromProduct:product];
            if (obj) {
                obj.contentMetadata.currency = mpEvent.currency;
                obj.contentMetadata.customMetadata[@"impression"] = impression;
                NSMutableArray<BranchUniversalObject*>* mutableCopy = [[NSMutableArray alloc] initWithArray:event.contentItems];
                [mutableCopy addObject:obj];
                event.contentItems = mutableCopy;
            }
        }
    }
    for (MPPromotion *promo in mpEvent.promotionContainer.promotions) {
        BranchUniversalObject *obj = [BranchUniversalObject new];
        obj.canonicalIdentifier = promo.promotionId;
        obj.title = promo.name;
        obj.contentMetadata.customMetadata[@"position"] = promo.position;
        obj.contentMetadata.customMetadata[@"creative"] = promo.creative;
        NSMutableArray<BranchUniversalObject*>* mutableCopy = [[NSMutableArray alloc] initWithArray:event.contentItems];
        [mutableCopy addObject:obj];
        event.contentItems = mutableCopy;
    }
    NSMutableDictionary<NSString*, NSString*>* mutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:event.customData];
    if (mpEvent.customAttributes != nil) {
        [mutableDictionary addEntriesFromDictionary:[self stringDictionaryFromDictionary:mpEvent.customAttributes]];
        event.customData = mutableDictionary;
    }
    mutableDictionary[@"product_list_name"] = mpEvent.productListName;
    mutableDictionary[@"product_list_source"] = mpEvent.productListSource;
    mutableDictionary[@"screen_name"] = mpEvent.screenName;
    mutableDictionary[@"checkout_options"] = mpEvent.checkoutOptions;
    event.currency = mpEvent.currency;
    event.affiliation = mpEvent.transactionAttributes.affiliation;
    event.coupon = mpEvent.transactionAttributes.couponCode;
    event.shipping = [self decimal:mpEvent.transactionAttributes.shipping];
    event.tax = [self decimal:mpEvent.transactionAttributes.tax];
    event.revenue = [self decimal:mpEvent.transactionAttributes.revenue];
    event.transactionID = mpEvent.transactionAttributes.transactionId;
    NSInteger checkoutStep = mpEvent.checkoutStep;
    if (checkoutStep >= 0 && checkoutStep < (NSInteger) 0x7fffffff) {
        mutableDictionary[@"checkout_step"] =
            [NSString stringWithFormat:@"%ld", (long) mpEvent.checkoutStep];
    }
    mutableDictionary[@"non_interactive"] = mpEvent.nonInteractive ? @"true" : @"false";
    event.customData = mutableDictionary;
    event.alias = mutableDictionary[@"customer_event_alias"];
    return event;
}

@end
