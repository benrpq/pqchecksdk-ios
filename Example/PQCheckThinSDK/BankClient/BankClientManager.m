//
//  EntityClientManager.m
//  Pods
//
//  Created by CJ on 01/02/2016.
//
//

#import <RestKit/RestKit.h>
#import <PQCheckSDK/APIManager.h>
#import "BankClientManager.h"
#import "BankAccount.h"
#import "Payment.h"
#import "AccountCollection.h"
#import "Enrolment.h"

@interface BankClientManager ()
{
    RKObjectManager *_objectManager;
}
@end

static NSString*  kEnrolAPIPath   = @"enrol";
static NSString*  kAccountAPIPath = @"accounts";
static NSString*  kPaymentAPIPath = @"payment";
static NSString*  kDefaultProfile = @"pqcheck";

@implementation BankClientManager

+ (BankClientManager *)defaultManager
{
    static BankClientManager *_defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[BankClientManager alloc] init];
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

- (void)enrolUserWithUUID:(NSString *)userUUID
               completion:(void (^)(Enrolment *enrolment, NSError *error))completion
{
    assert(_objectManager != nil);
    assert(_objectManager.HTTPClient != nil);
    assert(_objectManager.HTTPClient.baseURL != nil);
    
    // Set the appropriate accept-header
    [_objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    
    RKObjectMapping *enrolmentMapping = [RKObjectMapping mappingForClass:[Enrolment class]];
    [enrolmentMapping addAttributeMappingsFromDictionary:[Enrolment mapping]];
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:enrolmentMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    [_objectManager addResponseDescriptor:responseDescriptor];

    // Perform GET request
    NSString *accountPath = [NSString stringWithFormat:@"%@/%@", userUUID, kEnrolAPIPath];
    [_objectManager getObjectsAtPath:accountPath
                          parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 completion([mappingResult firstObject], nil);
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 completion(nil, error);
                             }];
}

- (void)getAccountsWithUserUUID:(NSString *)userUUID
                     completion:(void (^)(NSArray *accounts, NSError *error))completion;
{
    assert(_objectManager != nil);
    assert(_objectManager.HTTPClient != nil);
    assert(_objectManager.HTTPClient.baseURL != nil);

    // Set the appropriate accept-header
    [_objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    
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
                    completion:(void (^)(Payment *payment, NSError *))completion
{
    assert(_objectManager != nil);
    assert(_objectManager.HTTPClient != nil);
    assert(_objectManager.HTTPClient.baseURL != nil);
    
    [_objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    
    // Set the appropriate accept-header
    [_objectManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    
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
        completion(payment, nil);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

- (void)viewAuthorisationForPayment:(Payment *)payment
                         completion:(void (^)(Authorisation *authorisation, NSError *error))completion
{
    NSString *approvalUUID = [[NSURL URLWithString:payment.approvalUri] lastPathComponent];
    
    // Make sure that APIManager points to a correct endpoint
    NSString *currentEndpoint = [[APIManager sharedManager] currentPQCheckEndpoint];
    NSURL *baseURL = [NSURL URLWithString:[[NSURL URLWithString:@"/" relativeToURL:[NSURL URLWithString:payment.approvalUri]] absoluteString]];
    [[APIManager sharedManager] setBaseURL:baseURL];
    
    [[APIManager sharedManager] viewAuthorisationRequestWithUUID:approvalUUID completion:^(Authorisation *authorisation, NSError *error) {
        
        if (error == nil)
        {
            completion(authorisation, nil);
        }
        else
        {
            completion(nil, error);
        }
        
        // Revert the endpoint configuration
        [[APIManager sharedManager] setBaseURL:[NSURL URLWithString:currentEndpoint]];
    }];
}

@end
