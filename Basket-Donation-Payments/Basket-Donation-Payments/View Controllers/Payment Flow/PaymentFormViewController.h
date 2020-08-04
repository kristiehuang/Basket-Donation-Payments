//
//  PaymentFormViewController.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/27/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Basket.h"

NS_ASSUME_NONNULL_BEGIN

@interface PaymentFormViewController : UIViewController
@property (nonatomic, strong) Basket* basket;
@property (nonatomic, strong) NSNumber *totalAmount;
@property (strong) NSString *paymentIntentClientSecret;
@property (strong) NSString *paymentIntentId;

@end

NS_ASSUME_NONNULL_END
