//
//  NonprofitTransaction.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/28/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "NonprofitTransaction.h"

@implementation NonprofitTransaction

@dynamic nonprofit;
@dynamic percentageToNonprofit;
@dynamic stripeTransferId;

+ (nonnull NSString *)parseClassName {
    return @"NonprofitTransaction";
}

@end
