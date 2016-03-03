This document shows an example application of the deployment of PQCheck in retail banking application. PQCheck is used to approve  a transaction of a high-value payment. The term **approve** in the context of PQCheck means creating a *video signature* that binds the user to his/her transaction. 

>**Note** The documentation for PQCheck iOS SDK is available at [PQCheck SDK for iOS Reference](../../SDK/html/index.html).

In this example banking application, we have three components:-

1. PQCheck engine or server;
2. Bank application server;
3. Bank mobile client application.

The interaction amongst these components are depicted on the figure below. The PQCheckSDK for iOS sits on the bank iOS client application.
![Bank Deployment Architecture](https://post-quantum.com/assets/images/pqcheck/architecture.png "Bank Deployment Architecture")

The bank mobile client application implements three simple functions, namely user enrolment, account/payment viewing and payment approval.

##**User Enrolment**
Each user has a unique `userIdentifier` and a user has to be enrolled to PQCheck engine. The enrolment function is provided by `BankClientManager` object and this is how it is done.

    [[BankClientManager defaultManager] enrolUserWithUUID:userIdentifier 
                                               completion:^(Enrolment *enrolment, NSError *error) 
    {
        // Do your UI stuff here

        if (error == nil)
        {
            // Now we have a valid Enrolment object, pass it to PQCheckManager 
            // to let it completes the enrolment process
            _manager = [[PQCheckManager alloc] init];
            _manager.delegate = self;
            // By default user pacing option is disabled, it can be
            // enabled by settting shouldPaceUser parameter to YES
            [_manager performEnrolmentWithTranscript:enrolment.transcript 
                                           uploadURI:[NSURL URLWithString:enrolment.uri]];
        }
        else
        {
            // An error has been encountered
        }
    }];

Once the enrolment process is completed, the following delegates of `PQCheckManager` will be invoked, depending on the outcome.

    - (void)PQCheckManagerDidFinishEnrolment:(PQCheckManager *)manager
    {
        // Let UserManager deals with the user
        [[UserManager defaultManager] addEnrolledUser:userIdentifier];
        [[UserManager defaultManager] setCurrentUserIdentifer:userIdentifier];

        // Do your UI work here
    }

    - (void)PQCheckManager:(PQCheckManager *)manager didFailWithError:(NSError *)error
    {
        // An error has occurred, you can present an alert here
    }


##**Get Accounts and Payments**
For each `userIdentifier`, the bank application server provides a set of accounts, each with a set of payments. They can be obtained using `BankClientManager` object as follows.

    [[BankClientManager defaultManager] getAccountsWithUserUUID:userIdentifier 
                                                     completion:^(NSArray *accounts, NSError *error) 
    {
        // Do your UI work here

        if (error)
        {
            // An error has occurred during fetching
        }
        else
        {
            // Now you have the set of accounts, update your UI
        }
    }];

##**Payment Approval**
Each payment is assigned a unique `paymentIdentifier` and the process to approve a payment is described below.

    // 1. Tell the bank application server that you want to approve a payment 
    // identified by paymentIdentifier. You can use BankClientManager object 
    // to do this job.
    [[BankClientManager defaultManager] approvePaymentWithUUID:paymentIdentifier 
                                                      userUUID:userIdentifier 
                                                    completion:^(Payment *payment, NSError *error) 
    {
        // 2. Make sure that the payment has not been approved yet.
        if (payment.approved == YES)
        {
            // Stop right here. This payment has been approved, 
            // warn the user about it

            return;
        }

        // Step 3 has the following two possibilities
        if (error == nil)
        {
            // 3a. Success, the Payment object contains a secret URI (approvalUri) 
            // to an authorisation. You need to view this authorisation to obtain 
            // the necessary information to do a selfie.
            // You can use PQCheck SDK to view the authorisation, but BankClientManager 
            // provides a convenient wrapper to do this job.
            [[BankClientManager defaultManager] viewAuthorisationForPayment:payment 
                                                                 completion:^(Authorisation *authorisation, NSError *error) 
            {
                // Step 4 has the following two possibilities
                if (error == nil)
                {
                    // 4a. Ok, you have successfully viewed the authorisation, 
                    // now start a selfie process
                    _manager = [[PQCheckManager alloc] initWithAuthorisation:authorisation];
                    [_manager setDelegate:self];
                    [_manager setShouldPaceUser:YES];
                    [_manager performAuthorisationWithDigest:authorisation.digest];
                }
                else
                {
                     // 4b. Oh no, an error has occurred. 
                     // You can show an alert to the user
                }
            }];
        }
        else
        {
            // 3b. Oh dear, the payment approval request is not successful. 
            // You can show an alert to the user 
        }
    }];

Once the selfie process on Step 4a above is completed, one of the following delegates of `PQCheckManager` will be invoked.

    - (void)PQCheckManager:(PQCheckManager *)manager didFinishWithAuthorisationStatus:(PQCheckAuthorisationStatus)status
    {
        // Check the status of authorisation
        if (status == kPQCheckAuthorisationStatusSuccessful)
        {
            // Great, your selfie is accepted.
            // Now, tell the bank application server that your payment 
            // has been approved. You can use BankClientManager object 
            // to do this and in fact it's the same call as how you 
            // started the whole process.
            [[BankClientManager defaultManager] approvePaymentWithUUID:paymentIdentifier 
                                                              userUUID:userIdentifier 
                                                            completion:^(Payment *payment, NSError *error) 
            {
                // Update your UI work, but remember to check 
                // whether or not the call is successful.
            }];
        }
        else if (status == kPQCheckAuthorisationStatusTimedOut)
        {
            // The authorisation has timed-out, you
            // may need to request for another one
        }
        else if (status == kPQCheckAuthorisationStatusCancelled)
        {
            // The authorisation has been cancelled by the user
        }
        else if (status == kPQCheckAuthorisationStatusOpen)
        {
            // Your previous selfie was not accepted,
            // please try again.
        }
    }

    - (void)PQCheckManager:(PQCheckManager *)manager didFailWithError:(NSError *)error
    {
        // An error has occurred while doing selfie.
        // You should alert the user about this.
    }

