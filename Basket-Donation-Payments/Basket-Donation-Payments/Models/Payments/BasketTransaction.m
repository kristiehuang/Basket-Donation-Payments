//
//  BasketTransaction.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/13/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "BasketTransaction.h"
#import "User.h"
#import "Basket.h"
#import "NonprofitTransaction.h"
@implementation BasketTransaction

@dynamic createdAt;
@dynamic madeByUser;
@dynamic totalAmount;
@dynamic basketRecipient;
@dynamic indivNonprofitTxs;
@dynamic stripePaymentIntentId;

+ (nonnull NSString *)parseClassName {
    return @"BasketTransaction";
}

@end
