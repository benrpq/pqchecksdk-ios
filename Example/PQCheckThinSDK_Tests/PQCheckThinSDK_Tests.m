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
