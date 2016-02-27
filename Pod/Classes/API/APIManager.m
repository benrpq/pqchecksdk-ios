//
//  APIManager.m
//  PQCheckSDK
//
//  Created by CJ on 22/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <RestKit/RestKit.h>
#import <AFNetworking/AFNetworking.h>
#import "APIManager.h"
#ifndef THINSDK
#import "APIKeyRequest.h"
#import "AuthorisationRequest.h"
#import "Attempts.h"
#import "Authenticity.h"
#import "BiometricEvaluations.h"
#import "CancelAuthorisationRequest.h"
#import "Enrolment.h"
#endif

static NSString* kPQCheckBaseDevelopmentURL = @"http://selfieguard-dev.elasticbeanstalk.com";
static NSString* kPQCheckBaseUnstableURL = @"https://beta-api-pqcheck.post-quantum.com";
static NSString* kPQCheckBaseStableURL = @"https://api-pqcheck.post-quantum.com";
static NSString* kPQCheckBaseDataCollectionURL = @"https://data-collection-pqcheck.post-quantum.com";

static NSString* kPQCheckAPIKeyPath = @"/key";
static NSString* kPQCheckAuthorisationPath = @"/authorisation";
static NSString* kPQCheckEnrolmentPath = @"/enrolment";

static NSString* kPQCheckSDKDefaultProfile = @"pqcheck";
static NSInteger kPQCheckSDKDefaultVersion = 1;

static NSString* kEnrolmentVideoName = @"sample";
static NSString* kAuthorisationVideoName = @"video";
static NSString* kVideoExtension = @"mp4";

@interface APIManager ()
{
    NSString *_endpoint;
    RKObjectManager *_objectManager;
    NSString *_profile;
    NSNumber *_version;
}
@end

@implementation APIManager

+ (APIManager *)sharedManager
{
    static APIManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[APIManager alloc] init];
    });
    return _sharedManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
#ifndef THINSDK
        [self setPQCheckEndpoint:kStableEndpoint];
#endif
        NSURL *baseURL = [NSURL URLWithString:[self currentPQCheckEndpoint]];
        AFHTTPClient* httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        
        _objectManager = [[RKObjectManager alloc] initWithHTTPClient:httpClient];
        
        _profile = kPQCheckSDKDefaultProfile;
        _version = @(kPQCheckSDKDefaultVersion);
        
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
#if DEBUG
        RKLogConfigureByName("RestKit", RKLogLevelDebug);
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
#endif
    }
    return self;
}

- (NSString *)currentPQCheckEndpoint
{
    return _endpoint;
}

#ifndef THINSDK
- (void)setPQCheckEndpoint:(PQCheckEndpoint)endpoint
{
    // Initialize HTTPClient
    _endpoint = kPQCheckBaseStableURL;
    switch (endpoint) {
        case kStableEndpoint:
            _endpoint = kPQCheckBaseStableURL;
            break;
        case kUnstableEndpoint:
            _endpoint = kPQCheckBaseUnstableURL;
            break;
        case kDevelopmentEndpoint:
            _endpoint = kPQCheckBaseDevelopmentURL;
            break;
        default:
            _endpoint = kPQCheckBaseDataCollectionURL;
            break;
    }
    
    NSURL *baseURL = [NSURL URLWithString:_endpoint];
    [self setBaseURL:baseURL];
}
#endif

- (void)setBaseURL:(NSURL *)baseURL
{
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

#ifndef THINSDK
- (void)createAPIKeyWithCredential:(NSURLCredential *)credential
                         namespace:(NSString *)apiNamespace
                        completion:(void (^)(APIKey *apiKey, NSError *error))completionBlock
{
    [_objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    
    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderWithMIMEType:RKMIMETypeJSON
                              profile:_profile
                              version:[_version stringValue]];
    
    // Set authorisation header
    if (credential != nil)
    {
        [[_objectManager HTTPClient] setAuthorizationHeaderWithUsername:[credential user]
                                                               password:[credential password]];
    }
    
    // Object mapping of the request
    RKObjectMapping *requestMapping = [RKObjectMapping mappingForClass:[APIKeyRequest class]];
    [requestMapping addAttributeMappingsFromDictionary:[APIKeyRequest mapping]];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[requestMapping inverseMapping]
                                                                                   objectClass:[APIKeyRequest class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodPOST];
    [_objectManager addRequestDescriptor:requestDescriptor];
    
    // Perform POST request
    APIKeyRequest *apiKeyRequest = [[APIKeyRequest alloc] initWithAPINamespace:apiNamespace];
    [_objectManager postObject:apiKeyRequest
                          path:kPQCheckAPIKeyPath
                    parameters:nil
                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                           NSHTTPURLResponse *httpResponse = operation.HTTPRequestOperation.response;
                           
                           NSURL *apiKeyURL = [NSURL URLWithString:[[httpResponse allHeaderFields] objectForKey:@"Location"]];
                           NSString *secretUUID = [apiKeyURL lastPathComponent];
                           
                           [self __fetchAPIKeyForSecretUUID:secretUUID
                                                 completion:^(APIKey *apiKey, NSError *error) {
                                                     completionBlock(apiKey, error);
                                                 }];
                       }
                       failure:^(RKObjectRequestOperation *operation, NSError *error) {
                           completionBlock(nil, error);
                       }];
}

- (void)__fetchAPIKeyForSecretUUID:(NSString *)secretUUID
                        completion:(void (^)(APIKey *apiKey, NSError *error))completionBlock
{
    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderWithMIMEType:RKMIMETypeJSON
                              profile:_profile
                              version:[_version stringValue]];
    
    // Object mapping of the response
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[APIKey class]];
    [responseMapping addAttributeMappingsFromDictionary:[APIKey mapping]];
    
    // Register the mapping with provider using a response descriptor
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    // Perform GET request
    NSString *apiKeyPath = [NSString stringWithFormat:@"%@/%@", kPQCheckAPIKeyPath, secretUUID];
    [_objectManager getObjectsAtPath:apiKeyPath
                          parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 APIKey *apiKey = [mappingResult firstObject];
                                 completionBlock(apiKey, nil);
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 completionBlock(nil, error);
                             }];
}

- (void)createAuthorisationWithAPIKey:(APIKey *)apiKey
                           userIdentifier:(NSString *)identifier
                        authorisationHash:(NSString *)authorisationHash
                                  summary:(NSString *)summary
                               completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock
{
    [_objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    
    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderWithMIMEType:RKMIMETypeJSON
                              profile:_profile
                              version:[_version stringValue]];
        
    // Set authorisation header
    if (apiKey != nil)
    {
        [[_objectManager HTTPClient] setAuthorizationHeaderWithUsername:apiKey.uuid
                                                               password:apiKey.secret];
    }
    
    // Object mapping of the request
    RKObjectMapping *requestMapping = [RKObjectMapping mappingForClass:[AuthorisationRequest class]];
    [requestMapping addAttributeMappingsFromDictionary:[AuthorisationRequest mapping]];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[requestMapping inverseMapping]
                                                                                   objectClass:[AuthorisationRequest class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodPOST];
    [_objectManager addRequestDescriptor:requestDescriptor];
    
    // Object mapping of the response
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Authorisation class]];
    [responseMapping addAttributeMappingsFromDictionary:[Authorisation mapping]];
    RKObjectMapping *linksMapping = [RKObjectMapping mappingForClass:[Links class]];
    RKObjectMapping *pathMapping = [RKObjectMapping mappingForClass:[URIPath class]];
    [pathMapping addAttributeMappingsFromDictionary:[URIPath mapping]];
    
    // Define the mapping relationship
    RKPropertyMapping *mapping = nil;
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"self"
                                                          toKeyPath:@"selfPath"
                                                        withMapping:pathMapping];
    [linksMapping addPropertyMapping:mapping];
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"upload-attempt"
                                                          toKeyPath:@"uploadAttemptPath"
                                                        withMapping:pathMapping];
    [linksMapping addPropertyMapping:mapping];
    
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"_links"
                                                          toKeyPath:@"links"
                                                        withMapping:linksMapping];
    [responseMapping addPropertyMapping:mapping];
    
    // Register the mapping with provider using a response descriptor
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    [_objectManager addResponseDescriptor:responseDescriptor];

    // Perform POST request
    AuthorisationRequest *authorisationRequest = [[AuthorisationRequest alloc] initWithUserIdentifier:identifier
                                                                                    authorisationHash:authorisationHash
                                                                                              summary:summary];
    [_objectManager postObject:authorisationRequest
                          path:kPQCheckAuthorisationPath
                    parameters:nil
                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                           Authorisation *authorisation = [mappingResult firstObject];
                           completionBlock(authorisation, nil);
                       }
                       failure:^(RKObjectRequestOperation *operation, NSError *error) {
                           completionBlock(nil, error);
                       }];
}

- (void)viewAuthorisationRequestWithAPIKey:(APIKey *)apiKey
                                          UUID:(NSString *)uuid
                                    completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock
{
    assert(_objectManager != nil);
    
    // Set authorisation header
    if (apiKey != nil)
    {
        [[_objectManager HTTPClient] setAuthorizationHeaderWithUsername:apiKey.uuid
                                                               password:apiKey.secret];
    }

    [self __viewAuthorisationRequestUUID:uuid completion:^(Authorisation *authorisation, NSError *error) {
        completionBlock(authorisation, error);
    }];
}
#else
- (void)viewAuthorisationRequestWithUUID:(NSString *)uuid
                              completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock
{
    assert(_objectManager != nil);
    
    [self __viewAuthorisationRequestUUID:uuid completion:^(Authorisation *authorisation, NSError *error) {
        completionBlock(authorisation, error);
    }];
}
#endif

- (void)__viewAuthorisationRequestUUID:(NSString *)uuid
                            completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock
{
    [_objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    
    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderWithMIMEType:RKMIMETypeJSON
                              profile:_profile
                              version:[_version stringValue]];
    
    // Object mapping of the response
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Authorisation class]];
    [responseMapping addAttributeMappingsFromDictionary:[Authorisation mapping]];
#ifndef THINSDK
    RKObjectMapping *attemptsMapping = [RKObjectMapping mappingForClass:[Attempts class]];
    [attemptsMapping addAttributeMappingsFromDictionary:[Attempts mapping]];
    RKObjectMapping *biometricEvaluationsMapping = [RKObjectMapping mappingForClass:[BiometricEvaluations class]];
    [biometricEvaluationsMapping addAttributeMappingsFromDictionary:[BiometricEvaluations mapping]];
    RKObjectMapping *authenticityMapping = [RKObjectMapping mappingForClass:[Authenticity class]];
    [authenticityMapping addAttributeMappingsFromDictionary:[Authenticity mapping]];
#endif
    RKObjectMapping *linksMapping = [RKObjectMapping mappingForClass:[Links class]];
    RKObjectMapping *pathMapping = [RKObjectMapping mappingForClass:[URIPath class]];
    [pathMapping addAttributeMappingsFromDictionary:[URIPath mapping]];
    
    // Define the mapping relationship
    RKPropertyMapping *mapping = nil;
#ifndef THINSDK
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"authenticity"
                                                          toKeyPath:@"authenticity"
                                                        withMapping:authenticityMapping];
    [biometricEvaluationsMapping addPropertyMapping:mapping];
    
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"biometricEvaluations"
                                                          toKeyPath:@"biometricEvaluations"
                                                        withMapping:biometricEvaluationsMapping];
    [attemptsMapping addPropertyMapping:mapping];
    
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"attempts"
                                                          toKeyPath:@"attempts"
                                                        withMapping:attemptsMapping];
    [responseMapping addPropertyMapping:mapping];
#endif
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"self"
                                                          toKeyPath:@"selfPath"
                                                        withMapping:pathMapping];
    [linksMapping addPropertyMapping:mapping];
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"upload-attempt"
                                                          toKeyPath:@"uploadAttemptPath"
                                                        withMapping:pathMapping];
    [linksMapping addPropertyMapping:mapping];
    
    mapping = [RKRelationshipMapping relationshipMappingFromKeyPath:@"_links"
                                                          toKeyPath:@"links"
                                                        withMapping:linksMapping];
    [responseMapping addPropertyMapping:mapping];
    
    // Register the mapping with provider using a response descriptor
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    // Perform GET request
    NSString *authorisationPath = [NSString stringWithFormat:@"%@/%@", kPQCheckAuthorisationPath, uuid];
    [_objectManager getObjectsAtPath:authorisationPath
                          parameters:nil
                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                 Authorisation *authorisation = [mappingResult firstObject];
                                 completionBlock(authorisation, nil);
                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                 completionBlock(nil, error);
                             }];
}

#ifndef THINSDK
- (void)cancelAuthorisationRequestWithUUID:(NSString *)uuid
                                completion:(void (^)(NSError *error))completionBlock
{
    [_objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];

    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderWithMIMEType:RKMIMETypeJSON
                              profile:_profile
                              version:[_version stringValue]];
    
    // Object mapping of the request
    RKObjectMapping *requestMapping = [RKObjectMapping mappingForClass:[CancelAuthorisationRequest class]];
    [requestMapping addAttributeMappingsFromDictionary:[CancelAuthorisationRequest mapping]];
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[requestMapping inverseMapping]
                                                                                   objectClass:[CancelAuthorisationRequest class]
                                                                                   rootKeyPath:nil
                                                                                        method:RKRequestMethodPATCH];
    [_objectManager addRequestDescriptor:requestDescriptor];
    
    // Perform PATCH request
    CancelAuthorisationRequest *object = [[CancelAuthorisationRequest alloc] init];
    NSString *authorisationPath = [NSString stringWithFormat:@"%@/%@", kPQCheckAuthorisationPath, uuid];
    [_objectManager patchObject:object
                           path:authorisationPath
                     parameters:nil
                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                            completionBlock(nil);
                        }
                        failure:^(RKObjectRequestOperation *operation, NSError *error) {
                            completionBlock(error);
                        }];
}
#endif

- (void)uploadAttemptWithAuthorisation:(Authorisation *)authorisation
                              mediaURL:(NSURL *)mediaURL
                            completion:(void (^)(UploadAttempt *uploadAttempt, NSError *error))completionBlock
{
    // Make sure that the given URL is valid and the corresponding resource exists
    if ([mediaURL isFileURL] == NO ||
        [mediaURL checkResourceIsReachableAndReturnError:nil] == NO)
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedStringFromTable(@"The given URL is invalid, either not a file URL or the resource does not exist", @"PQCheckSDK", nil) forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [[NSError alloc] initWithDomain:@"PQCheckSDKErrorDomain" code:NSURLErrorBadURL userInfo:userInfo];
        completionBlock(nil, error);
        
        return;
    }
    
    NSURL *url = [NSURL URLWithString:authorisation.links.uploadAttemptPath.href];
    NSURL *baseURL = [NSURL URLWithString:[[NSURL URLWithString:@"/" relativeToURL:url] absoluteString]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    _objectManager = [[RKObjectManager alloc] initWithHTTPClient:httpClient];
    
    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderWithMIMEType:RKMIMETypeJSON
                              profile:_profile
                              version:[_version stringValue]];
    
    // Object mapping of the response
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[UploadAttempt class]];
    [responseMapping addAttributeMappingsFromDictionary:[UploadAttempt mapping]];
    
    // Register the mapping with provider using a response descriptor
    NSIndexSet *successSet = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    NSMutableIndexSet *statusCodes = [[NSMutableIndexSet alloc] initWithIndexSet:successSet];
    [statusCodes addIndex:409];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    // Perform multipart POST request
    NSURL *attemptURL = [NSURL URLWithString:[[[authorisation links] uploadAttemptPath] href]];
    NSString *uploadAttemptPath = [attemptURL path];
    NSMutableURLRequest *urlRequest = [_objectManager multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:uploadAttemptPath parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // POST the media file
        NSString *fileName = [[authorisation uuid] stringByAppendingPathExtension:kVideoExtension];
        NSString *MIMEType = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(kUTTypeMPEG4, kUTTagClassMIMEType));
        [formData appendPartWithFileURL:mediaURL name:kAuthorisationVideoName fileName:fileName mimeType:MIMEType error:nil];
    }];

    RKObjectRequestOperation *operation =
    [_objectManager objectRequestOperationWithRequest:urlRequest
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  UploadAttempt *uploadAttempt = [mappingResult firstObject];
                                                  completionBlock(uploadAttempt, nil);
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  completionBlock(nil, error);
                                              }];
    [_objectManager enqueueObjectRequestOperation:operation];
}

#ifndef THINSDK
- (void)enrolUserWithAPIKey:(APIKey *)apiKey
                 userIdentifier:(NSString *)identifier
                      reference:(NSString *)reference
                     transcript:(NSString *)transcript
                       mediaURL:(NSURL *)mediaURL
                     completion:(void (^)(NSError *error))completionBlock
{
    // Make sure that the given URL is valid and the corresponding resource exists
    if ([mediaURL isFileURL] == NO ||
        [mediaURL checkResourceIsReachableAndReturnError:nil] == NO)
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedStringFromTable(@"The given URL is invalid, either not a file URL or the resource does not exist", @"PQCheckSDK", nil) forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [[NSError alloc] initWithDomain:@"PQCheckSDKErrorDomain" code:NSURLErrorBadURL userInfo:userInfo];
        completionBlock(error);
        
        return;
    }
    
    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderWithMIMEType:RKMIMETypeJSON
                              profile:_profile
                              version:[_version stringValue]];
    
    // Object mapping of the response
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[NSNull class]];
    
    // Register the mapping with provider using a response descriptor
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    [_objectManager addResponseDescriptor:responseDescriptor];

    // Set authorisation header
    if (apiKey != nil)
    {
        [[_objectManager HTTPClient] setAuthorizationHeaderWithUsername:apiKey.uuid
                                                               password:apiKey.secret];
    }
    
    Enrolment *enrolment = [[Enrolment alloc] initWithUserIdentifier:identifier reference:reference transcript:transcript];
    
    // Perform multipart POST request
    NSMutableURLRequest *urlRequest = [_objectManager multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:kPQCheckEnrolmentPath parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {

        [formData appendPartWithFormData:[enrolment.userIdentifier dataUsingEncoding:NSUTF8StringEncoding] name:@"userIdentifier"];
        
        [formData appendPartWithFormData:[enrolment.reference dataUsingEncoding:NSUTF8StringEncoding] name:@"reference"];
        
        [formData appendPartWithFormData:[enrolment.transcript dataUsingEncoding:NSUTF8StringEncoding] name:@"transcript"];
        
        // POST the media file
        NSString *fileName = [kEnrolmentVideoName stringByAppendingPathExtension:kVideoExtension];
        NSString *MIMEType = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(kUTTypeMPEG4, kUTTagClassMIMEType));
        [formData appendPartWithFileURL:mediaURL name:kEnrolmentVideoName fileName:fileName mimeType:MIMEType error:nil];
    }];
    
    RKObjectRequestOperation *operation =
    [_objectManager objectRequestOperationWithRequest:urlRequest
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  completionBlock(nil);
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  completionBlock(error);
                                              }];
    [_objectManager enqueueObjectRequestOperation:operation];
}
#else
- (void)enrolUserWithMediaURL:(NSURL *)mediaURL
                    uploadURL:(NSURL *)uploadURL
                   completion:(void (^)(NSError *error))completionBlock
{
    // Make sure that the given URL is valid and the corresponding resource exists
    if ([mediaURL isFileURL] == NO ||
        [mediaURL checkResourceIsReachableAndReturnError:nil] == NO)
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedStringFromTable(@"The given URL is invalid, either not a file URL or the resource does not exist", @"PQCheckSDK", nil) forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [[NSError alloc] initWithDomain:@"PQCheckSDKErrorDomain" code:NSURLErrorBadURL userInfo:userInfo];
        completionBlock(error);
        
        return;
    }
    
    // Make sure that APIManager points to a correct endpoint
    NSString *currentEndpoint = [[APIManager sharedManager] currentPQCheckEndpoint];
    NSURL *baseURL = [NSURL URLWithString:[[NSURL URLWithString:@"/" relativeToURL:uploadURL] absoluteString]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    _objectManager = [[RKObjectManager alloc] initWithHTTPClient:httpClient];
    
    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderWithMIMEType:RKMIMETypeJSON
                              profile:_profile
                              version:[_version stringValue]];
    
    // Object mapping of the response
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[NSNull class]];
    
    // Register the mapping with provider using a response descriptor
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                            method:RKRequestMethodPOST
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    // Perform multipart POST request
    NSMutableURLRequest *urlRequest = [_objectManager multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:[uploadURL path] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        // POST the media file
        NSString *fileName = [kEnrolmentVideoName stringByAppendingPathExtension:kVideoExtension];
        NSString *MIMEType = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(kUTTypeMPEG4, kUTTagClassMIMEType));
        [formData appendPartWithFileURL:mediaURL name:kEnrolmentVideoName fileName:fileName mimeType:MIMEType error:nil];
    }];
    
    RKObjectRequestOperation *operation =
    [_objectManager objectRequestOperationWithRequest:urlRequest
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  // Revert the endpoint configuration
                                                  [[APIManager sharedManager] setBaseURL:[NSURL URLWithString:currentEndpoint]];

                                                  completionBlock(nil);
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  // Revert the endpoint configuration
                                                  [[APIManager sharedManager] setBaseURL:[NSURL URLWithString:currentEndpoint]];

                                                  completionBlock(error);
                                              }];
    [_objectManager enqueueObjectRequestOperation:operation];
}
#endif

@end
