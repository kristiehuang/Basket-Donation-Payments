//
//  PaymentIntent.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/28/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasketTransaction.h"

NS_ASSUME_NONNULL_BEGIN

@interface StripePaymentIntent : NSObject
@property (nonatomic, strong) NSString *paymentId;
@property (nonatomic, strong) NSNumber *totalAmount;
@property (nonatomic, strong) BasketTransaction *basketTx;
@property (nonatomic, strong) NSString *currencyCode;
@property (nonatomic, strong) NSString *transferGroup;

@end

NS_ASSUME_NONNULL_END
