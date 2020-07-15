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

@dynamic user; //user that owns nonprofit
@dynamic nonprofitId;
@dynamic nonprofitName;
@dynamic nonprofitDescription;
@dynamic profilePicFile;
@dynamic headerPicFile;
@dynamic totalDonationsValue;
@dynamic basketTransactionsMadeToNonprofit;
@dynamic belongsInBaskets;
@dynamic websiteUrl;
@dynamic category;
@dynamic verificationFiles;

+ (nonnull NSString *)parseClassName {
    return @"Nonprofit";
}

@end
