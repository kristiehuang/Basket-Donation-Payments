//
//  LoginWebKitViewController.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/29/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Nonprofit.h"
#import "User.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoginWebKitViewController : UIViewController
@property (nonatomic, strong) Nonprofit *nonprofit;
@property (nonatomic, strong) User *user;

@end

NS_ASSUME_NONNULL_END
