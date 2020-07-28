//
//  BasketTransaction.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/13/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@class User;
@class Basket;
@class NonprofitTransaction;

@interface BasketTransaction : PFObject<PFSubclassing>

/** Already has: createdAt, objectId. */
//TODO: PAYMENT METHOD; UNKNWON TYPE, NEED TO SEE HOW PAYPAL SDK WORKS
@property (nonatomic, strong) User *madeByUser;
@property (nonatomic) double totalAmount;
@property (nonatomic, strong) Basket *basketRecipient;
@property (nonatomic, strong) NSArray<NonprofitTransaction*> *indivNonprofitTxs;
@property (nonatomic, strong) NSString *stripePaymentIntentId;

@end

NS_ASSUME_NONNULL_END
