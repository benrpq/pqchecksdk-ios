//
//  PQCheckThinSDK_Tests.m
//  PQCheckThinSDK_Tests
//
//  Created by CJ on 02/03/2016.
//  Copyright © 2016 CJ Tjhai. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <PQCheckSDK/APIManager.h>
#import <PQCheckSDK/Authorisation.h>
#import <PQCheckSDK/UploadAttempt.h>
#import "ILTesting/ILCannedURLProtocol.h"
#import "MockedPQCheckServer.h"

SPEC_BEGIN(PQCheckAPI)

describe(@"PQCheck API", ^{
    
    __block Authorisation *_authorisation = nil;
    
    beforeEach(^{

        [NSURLProtocol registerClass:[ILCannedURLProtocol class]];
        
        [ILCannedURLProtocol setCannedStatusCode:200];
        NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
        [headers setObject:@"application/json" forKey:@"Content-Type"];
        [ILCannedURLProtocol setCannedHeaders:headers];
    });
    
    afterEach(^{
        
        [NSURLProtocol unregisterClass:[ILCannedURLProtocol class]];
    });
    
    it(@"View Authorisation", ^{
        
        MockedPQCheckServer *delegate = [[MockedPQCheckServer alloc] init];
        
        [ILCannedURLProtocol setDelegate:delegate];
        [ILCannedURLProtocol setSupportedMethods:@[@"GET"]];
        
        __block PQCheckAuthorisationStatus status = kPQCheckAuthorisationStatusUnknown;
        __block NSString *uploadAttempt = @"";
        __block BOOL mustHaveHistory = YES;
        
        NSURL *url = [NSURL URLWithString:@"https://pqcheck-application-server/authorisation/bcd767ff-141f-41b0-b9f4-302f7647eba1"];
        [[APIManager sharedManager] viewAuthorisationAtURL:url completion:^(Authorisation *authorisation, NSError *error) {
            if (error == nil)
            {
                _authorisation = authorisation;
                status = authorisation.authorisationStatus;
                uploadAttempt = [[[authorisation links] uploadAttemptPath] href];
                mustHaveHistory = authorisation.mustHaveHistory;
            }
        }];
        
        [[expectFutureValue([NSNumber numberWithInt:status]) shouldEventually] equal:[NSNumber numberWithInt:kPQCheckAuthorisationStatusTimedOut]];
        [[expectFutureValue(uploadAttempt) shouldEventually] equal:@"https://pqcheck-server/authorisation/bcd767ff-141f-41b0-b9f4-302f7647eba1/attempt"];
        [[expectFutureValue([NSNumber numberWithInt:mustHaveHistory]) shouldEventually] equal:[NSNumber numberWithBool:NO]];
    });
    
    it(@"Upload Attempt", ^{
        
        MockedPQCheckServer *delegate = [[MockedPQCheckServer alloc] init];
        
        [ILCannedURLProtocol setDelegate:delegate];
        [ILCannedURLProtocol setSupportedMethods:@[@"POST"]];
        
        __block PQCheckAuthorisationStatus status;
        __block NSString *nextDigest = @"";
        __block NSNumber *attemptNumber = [NSNumber numberWithInt:0];
        
        NSBundle *bundle = [NSBundle bundleForClass:self.class];
        NSString *resource = [bundle pathForResource:@"authorisation" ofType:@"json"];
        NSURL *mediaURL = [NSURL fileURLWithPath:resource];
        [[APIManager sharedManager] uploadAttemptWithAuthorisation:_authorisation mediaURL:mediaURL completion:^(UploadAttempt *uploadAttempt, NSError *error) {
            if (error == nil)
            {
                status = [AuthorisationStatus authorisationStatusValueOfString:uploadAttempt.status];
                nextDigest = uploadAttempt.nextDigest;
                attemptNumber = [NSNumber numberWithUnsignedInteger:uploadAttempt.number];
            }
        }];
        
        [[expectFutureValue([NSNumber numberWithInt:status]) shouldEventually] equal:[NSNumber numberWithInt:kPQCheckAuthorisationStatusSuccessful]];
        [[expectFutureValue(nextDigest) shouldEventually] equal:@"150195"];
        [[expectFutureValue(attemptNumber) shouldEventually] equal:[NSNumber numberWithUnsignedInteger:1]];
    });
});
SPEC_END
