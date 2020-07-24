//
//  NonprofitSignupViewController.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface NonprofitSignupViewController : UIViewController
@property (nonatomic, strong) Nonprofit *nonprofit;
@property (nonatomic, strong) User *user;
@end

NS_ASSUME_NONNULL_END
