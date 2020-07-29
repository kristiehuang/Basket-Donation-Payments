//
//  NonprofitTransaction.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/28/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <Parse/Parse.h>
#import "StripeTransfer.h"
#import "Nonprofit.h"

NS_ASSUME_NONNULL_BEGIN

@interface NonprofitTransaction : PFObject<PFSubclassing>

@property (nonatomic, strong) Nonprofit *nonprofit;
@property (nonatomic, strong) NSNumber *percentageToNonprofit;
@property (nonatomic, strong) NSString *stripeTransferId;

@end

NS_ASSUME_NONNULL_END
