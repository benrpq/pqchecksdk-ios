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
