//
//  EntityClientManager.m
//  Pods
//
//  Created by CJ on 01/02/2016.
//
//

#import <RestKit/RestKit.h>
#import <PQCheckSDK/APIManager.h>
#import "EntityClientManager.h"
#import "BankAccount.h"
#import "Payment.h"
#import "AccountCollection.h"

@interface EntityClientManager ()
{
    RKObjectManager *_objectManager;
    NSString *_profile;
    NSNumber *_version;
}
@end

static NSString*  kAccountAPIPath = @"accounts";
static NSString*  kPaymentAPIPath = @"payment";
static NSString*  kDefaultProfile = @"pqcheck";
static NSUInteger kDefaultVersion = 1;

@implementation EntityClientManager

+ (EntityClientManager *)defaultManager
{
    static EntityClientManager *_defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[EntityClientManager alloc] init];
    });
    return _defaultManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // NOTE:
        // iOS has a strict security requirements. By default, a HTTP connection is not allowed by
        // default. In order to override this behaviour, we need to add an entry in Info.plist file:
        // 1. Add NSAppTransportSecurity row as a Dictionary
        // 2. Add NSAllowsArbitraryLoads as a child of (1) and set it to Boolean YES
        NSURL *baseURL = [NSURL URLWithString:@"http://bank-of-jorge.eu-west-1.elasticbeanstalk.com"];
        AFHTTPClient* httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        
        _objectManager = [[RKObjectManager alloc] initWithHTTPClient:httpClient];
        
        _profile = kDefaultProfile;
        _version = @(kDefaultVersion);
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
#if DEBUG
        RKLogConfigureByName("RestKit", RKLogLevelDebug);
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
#endif
    }
    return self;
}

- (void)setBaseURL:(NSURL *)baseURL
{
    assert(_objectManager != nil);
    
    AFHTTPClient* httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [_objectManager setHTTPClient:httpClient];
}

- (void)setProfile:(NSString *)profile
{
    _profile = profile;
}

- (void)setVersion:(NSNumber *)version
{
    _version = version;
}

- (void)getAccountsWithUserUUID:(NSString *)userUUID
                     completion:(void (^)(NSArray *accounts, NSError *error))completion;
{
    assert(_objectManager != nil);
    assert(_objectManager.HTTPClient != nil);
    assert(_objectManager.HTTPClient.baseURL != nil);

    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderWithMIMEType:RKMIMETypeJSON
                              profile:_profile
                              version:[_version stringValue]];
    
    // Object mapping of the response
    RKObjectMapping *accountCollectionMapping = [RKObjectMapping mappingForClass:[AccountCollection class]];
    [accountCollectionMapping addAttributeMappingsFromDictionary:[AccountCollection mapping]];
    RKObjectMapping *paymentMapping = [RKObjectMapping mappingForClass:[Payment class]];
    [paymentMapping addAttributeMappingsFromDictionary:[Payment mapping]];
    RKObjectMapping *bankAccountMapping = [RKObjectMapping mappingForClass:[BankAccount class]];
    [bankAccountMapping addAttributeMappingsFromDictionary:[BankAccount mapping]];
    RKPropertyMapping *mapping = nil;
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"from" toKeyPath:@"from" withMapping:bankAccountMapping];
    [paymentMapping addPropertyMapping:mapping];
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"to" toKeyPath:@"to" withMapping:bankAccountMapping];
    [paymentMapping addPropertyMapping:mapping];
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"payments" toKeyPath:@"payments" withMapping:paymentMapping];
    [accountCollectionMapping addPropertyMapping:mapping];
    
    // Register the mapping with provider using a response descriptor
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:accountCollectionMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:@"accounts"
                                                                                       statusCodes:statusCodes];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    // Perform GET request
    NSString *accountPath = [NSString stringWithFormat:@"%@/%@", userUUID, kAccountAPIPath];
    [_objectManager getObjectsAtPath:accountPath
                          parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 completion([mappingResult array], nil);
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 completion(nil, error);
                             }];
}

- (void)approvePaymentWithUUID:(NSString *)paymentUUID
                      userUUID:(NSString *)userUUID
                    completion:(void (^)(Authorisation *authorisation, NSError *error))completion
{
    assert(_objectManager != nil);
    assert(_objectManager.HTTPClient != nil);
    assert(_objectManager.HTTPClient.baseURL != nil);

    [_objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    
    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderWithMIMEType:RKMIMETypeJSON
                              profile:_profile
                              version:[_version stringValue]];
    
    RKObjectMapping *paymentMapping = [RKObjectMapping mappingForClass:[Payment class]];
    [paymentMapping addAttributeMappingsFromDictionary:[Payment mapping]];
    RKObjectMapping *bankAccountMapping = [RKObjectMapping mappingForClass:[BankAccount class]];
    [bankAccountMapping addAttributeMappingsFromDictionary:[BankAccount mapping]];
    RKPropertyMapping *mapping = nil;
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"from" toKeyPath:@"from" withMapping:bankAccountMapping];
    [paymentMapping addPropertyMapping:mapping];
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"to" toKeyPath:@"to" withMapping:bankAccountMapping];
    [paymentMapping addPropertyMapping:mapping];

    // Register the mapping with provider using a response descriptor
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:paymentMapping
                                                                                            method:RKRequestMethodPATCH
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    // Perform PATCH request
    NSString *paymentPath = [NSString stringWithFormat:@"%@/%@/%@", userUUID, kPaymentAPIPath, paymentUUID];
    [_objectManager patchObject:nil path:paymentPath parameters:@{@"approved": @(YES)} success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        Payment *payment = [mappingResult firstObject];
        
        NSString *approvalUUID = [[NSURL URLWithString:payment.approvalUri] lastPathComponent];
        [[APIManager sharedManager] viewAuthorisationRequestWithUUID:approvalUUID completion:^(Authorisation *authorisation, NSError *error) {
            if (error == nil)
            {
                completion(authorisation, nil);
            }
            else
            {
                completion(nil, error);
            }
        }];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

#pragma mark - Private methods

- (void)setAcceptHeaderWithMIMEType:(NSString *)MIMEType
                            profile:(NSString *)profile
                            version:(NSString *)version
{
    if (_objectManager == nil)
    {
        return;
    }
    
    NSString *acceptHeader = MIMEType;
    if (acceptHeader == nil)
    {
        acceptHeader = @"";
    }
    if (profile && [profile length] > 0)
    {
        acceptHeader = [acceptHeader stringByAppendingFormat:@"; profile=%@", profile];
    }
    if (version)
    {
        acceptHeader = [acceptHeader stringByAppendingFormat:@"; version=%@", version];
    }
    
    // We want to accept JSON type data
    if ([acceptHeader length] > 0)
    {
        [_objectManager setAcceptHeaderWithMIMEType:acceptHeader];
    }
}

@end
