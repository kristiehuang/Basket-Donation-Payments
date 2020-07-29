//
//  StripeTransfer.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/28/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StripeTransfer : NSObject
@property (nonatomic, strong) NSString *transferId;
@property (nonatomic, strong) NSNumber *amountTransferred;

/** Object type is "transfer". */
@property (nonatomic, strong) NSString *objectType;

/** Stripe ID of the recipient connected account. Required. */
@property (nonatomic, strong) NSString *destinationStripeId;

@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, strong) NSString *transferGroup;

@end

NS_ASSUME_NONNULL_END
