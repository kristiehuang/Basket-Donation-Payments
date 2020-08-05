//
//  Nonprofit.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/13/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "Nonprofit.h"
#import "User.h"

@implementation Nonprofit

@dynamic user; //User that owns nonprofit
@dynamic stripeAccountId;
@dynamic nonprofitName;
@dynamic nonprofitDescription;
@dynamic profilePicFile;
@dynamic totalDonationsValue;
@dynamic basketTransactionsMadeToNonprofit;
@dynamic belongsInBaskets;
@dynamic websiteUrlString;
@dynamic category;
@dynamic verificationFiles;

+ (nonnull NSString *)parseClassName {
    return @"Nonprofit";
}


@end
