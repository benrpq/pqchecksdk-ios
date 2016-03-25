/*
 * Copyright (C) 2016 Post-Quantum
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <MobileCoreServices/MobileCoreServices.h>
#import <RestKit/RestKit.h>
#import <AFNetworking/AFNetworking.h>
#import "APIManager.h"
#import "Authorisation.h"
#import "UploadAttempt.h"

static NSString* kPQCheckBaseStableURL = @"https://api-pqcheck.post-quantum.com";

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
    NSString *_profile;
    NSNumber *_version;
    NSURL *_baseURL;
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
        // We need some value that is not nil
        _endpoint = kPQCheckBaseStableURL;
        
        _baseURL = [NSURL URLWithString:[self currentPQCheckEndpoint]];
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

- (void)setBaseURL:(NSURL *)baseURL
{
    _baseURL = baseURL;
}

- (void)setProfile:(NSString *)profile
{
    _profile = profile;
}

- (void)setVersion:(NSNumber *)version
{
    _version = version;
}

- (void)setAcceptHeaderForObjectManager:(RKObjectManager *)objectManager
                           withMIMEType:(NSString *)MIMEType
                                profile:(NSString *)profile
                                version:(NSString *)version
{
    if (objectManager == nil)
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
        [objectManager setAcceptHeaderWithMIMEType:acceptHeader];
    }
}

- (void)viewAuthorisationAtURL:(NSURL *)url
                    completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock
{
    NSString *uuid = [url lastPathComponent];
    
    // Make sure that APIManager points to a correct endpoint
    NSString *currentEndpoint = [self currentPQCheckEndpoint];
    NSURL *baseURL = [NSURL URLWithString:[[NSURL URLWithString:@"/" relativeToURL:url] absoluteString]];
    [self setBaseURL:baseURL];
    
    __weak APIManager *weakSelf = self;
    [weakSelf __viewAuthorisationRequestUUID:uuid completion:^(Authorisation *authorisation, NSError *error) {
        completionBlock(authorisation, error);
        
        // Revert the endpoint configuration
        [weakSelf setBaseURL:[NSURL URLWithString:currentEndpoint]];
    }];
}

- (void)__viewAuthorisationRequestUUID:(NSString *)uuid
                            completion:(void (^)(Authorisation *authorisation, NSError *error))completionBlock
{
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:_baseURL];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:httpClient];
    
    [objectManager setRequestSerializationMIMEType:RKMIMETypeJSON];
    
    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderForObjectManager:objectManager
                             withMIMEType:RKMIMETypeJSON
                                  profile:_profile
                                  version:[_version stringValue]];
    
    // Object mapping of the response
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[Authorisation class]];
    [responseMapping addAttributeMappingsFromDictionary:[Authorisation mapping]];
    RKObjectMapping *linksMapping = [RKObjectMapping mappingForClass:[Links class]];
    RKObjectMapping *pathMapping = [RKObjectMapping mappingForClass:[HATEOASObject class]];
    [pathMapping addAttributeMappingsFromDictionary:[HATEOASObject mapping]];
    
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
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:statusCodes];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    // Perform GET request
    NSString *authorisationPath = [NSString stringWithFormat:@"%@/%@", kPQCheckAuthorisationPath, uuid];
    [objectManager getObjectsAtPath:authorisationPath
                         parameters:nil
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                Authorisation *authorisation = [mappingResult firstObject];
                                completionBlock(authorisation, nil);
                            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                completionBlock(nil, error);
                            }];
}

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
    _baseURL = [NSURL URLWithString:[[NSURL URLWithString:@"/" relativeToURL:url] absoluteString]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:_baseURL];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:httpClient];
    
    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderForObjectManager:objectManager
                             withMIMEType:RKMIMETypeJSON
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
    [objectManager addResponseDescriptor:responseDescriptor];
    
    // Perform multipart POST request
    NSURL *attemptURL = [NSURL URLWithString:[[[authorisation links] uploadAttemptPath] href]];
    NSString *uploadAttemptPath = [attemptURL path];
    NSMutableURLRequest *urlRequest = [objectManager multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:uploadAttemptPath parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        // POST the media file
        NSString *fileName = [[authorisation uuid] stringByAppendingPathExtension:kVideoExtension];
        NSString *MIMEType = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(kUTTypeMPEG4, kUTTagClassMIMEType));
        [formData appendPartWithFileURL:mediaURL name:kAuthorisationVideoName fileName:fileName mimeType:MIMEType error:nil];
    }];

    RKObjectRequestOperation *operation =
    [objectManager objectRequestOperationWithRequest:urlRequest
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  UploadAttempt *uploadAttempt = [mappingResult firstObject];
                                                  completionBlock(uploadAttempt, nil);
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  completionBlock(nil, error);
                                              }];
    [objectManager enqueueObjectRequestOperation:operation];
}

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
    NSString *currentEndpoint = [self currentPQCheckEndpoint];
    _baseURL = [NSURL URLWithString:[[NSURL URLWithString:@"/" relativeToURL:uploadURL] absoluteString]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:_baseURL];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:httpClient];
    
    // We want to accept JSON type data, plus profile and version if available
    [self setAcceptHeaderForObjectManager:objectManager
                             withMIMEType:RKMIMETypeJSON
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
    [objectManager addResponseDescriptor:responseDescriptor];
    
    // Perform multipart POST request
    NSMutableURLRequest *urlRequest = [objectManager multipartFormRequestWithObject:nil method:RKRequestMethodPOST path:[uploadURL path] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        // POST the media file
        NSString *fileName = [kEnrolmentVideoName stringByAppendingPathExtension:kVideoExtension];
        NSString *MIMEType = (__bridge NSString *)(UTTypeCopyPreferredTagWithClass(kUTTypeMPEG4, kUTTagClassMIMEType));
        [formData appendPartWithFileURL:mediaURL name:kEnrolmentVideoName fileName:fileName mimeType:MIMEType error:nil];
    }];
    
    __weak APIManager *weakSelf = self;
    RKObjectRequestOperation *operation =
    [objectManager objectRequestOperationWithRequest:urlRequest
                                             success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                 // Revert the endpoint configuration
                                                 [weakSelf setBaseURL:[NSURL URLWithString:currentEndpoint]];
                                                 
                                                 completionBlock(nil);
                                             }
                                             failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                 // Revert the endpoint configuration
                                                 [weakSelf setBaseURL:[NSURL URLWithString:currentEndpoint]];
                                                 
                                                 completionBlock(error);
                                             }];
    [objectManager enqueueObjectRequestOperation:operation];
}

@end
