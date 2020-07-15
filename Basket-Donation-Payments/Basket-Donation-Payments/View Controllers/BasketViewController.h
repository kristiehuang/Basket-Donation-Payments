//
//  BasketViewController.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Basket.h"

NS_ASSUME_NONNULL_BEGIN

@interface BasketViewController : UIViewController
@property (nonatomic, strong) Basket *basket;
@end

NS_ASSUME_NONNULL_END
