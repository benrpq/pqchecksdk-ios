//
//  Payment.m
//  PQCheckSample
//
//  Created by CJ Tjhai on 28/01/2016.
//  Copyright © 2016 Post-Quantum. All rights reserved.
//

#import "Payment.h"
#import "BankAccount.h"

@implementation Payment

- (NSString *)formattedAmount
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *currencySymbol = [locale displayNameForKey:NSLocaleCurrencySymbol value:self.currency];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.locale = locale;
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    return [currencySymbol stringByAppendingString:[formatter stringFromNumber:self.amount]];
}

- (NSString *)formattedDueDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, dd MMM yyyy"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.due];
    
    return [formatter stringFromDate:date];
}

+ (NSDictionary *)mapping
{
    return @{@"uuid": @"uuid",
             @"amount": @"amount",
             @"currency": @"currency",
             @"due": @"due",
             @"approved": @"approved",
             @"approvalUri": @"approvalUri"
             };
}

@end
