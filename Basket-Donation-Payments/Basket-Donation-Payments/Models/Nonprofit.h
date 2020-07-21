//
//  Nonprofit.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/13/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <Parse/Parse.h>
#import "BasketTransaction.h"
#import "Basket.h"

NS_ASSUME_NONNULL_BEGIN

@class User;

@interface Nonprofit : PFObject<PFSubclassing>

/** PFUser already has objectId, updatedAt, createdAt. */

@property (nonatomic) User *user; //user that owns nonprofit
@property (nonatomic, strong) NSString *nonprofitId; //TODO: set equal to objectId?
@property (nonatomic, strong) NSString *nonprofitName;

@property (nonatomic, strong) NSString *nonprofitDescription;
@property (nonatomic, strong) PFFileObject *profilePicFile;
@property (nonatomic, strong) PFFileObject *headerPicFile; //TODO: will this break if nil? since i didn't mark as nullable

@property (nonatomic) double totalDonationsValue;
@property (nonatomic, strong) NSArray<BasketTransaction*> *basketTransactionsMadeToNonprofit;
@property (nonatomic, strong) NSArray<Basket*> *belongsInBaskets;
//TODO: iNCLUDE PAYPAL PAYMENT INFO: paymentid, merchantId, email, etc. don't forget to @dynamic
@property (nonatomic, strong) NSString *websiteUrlString;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSArray<PFFileObject*> *verificationFiles;

@end

NS_ASSUME_NONNULL_END
