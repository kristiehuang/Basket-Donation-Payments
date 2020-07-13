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
@implementation BasketTransaction

@dynamic createdAt;
@dynamic basketTransactionId;  //initialize as objectId
@dynamic madeByUser;
@dynamic totalAmount;
@dynamic basketRecipient;
@dynamic indivNonprofitTxs;
//TODO: PAYMENT METHOD; UNKNWON TYPE, NEED TO SEE HOW PAYPAL SDK WORKS


+ (nonnull NSString *)parseClassName {
    return @"BasketTransaction";
}

@end
