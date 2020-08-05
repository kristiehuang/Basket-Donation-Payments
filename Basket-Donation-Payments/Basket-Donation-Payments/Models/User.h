//
//  User.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/13/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <Parse/Parse.h>
#import "BasketTransaction.h"

NS_ASSUME_NONNULL_BEGIN
@class Nonprofit;

@interface User : PFUser<PFSubclassing>
/** PFUser already has objectId, updaedAt, username, password, email, createdAt. */

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) PFFileObject *profilePicFile;
@property (nonatomic, strong, nullable) Nonprofit *nonprofit;
@property (nonatomic, strong) NSMutableArray<BasketTransaction*> *recentDonations;
@property (nonatomic, strong) NSMutableArray<Nonprofit*> *favoriteNonprofits;
@property (nonatomic, strong) NSMutableArray<Basket*> *favoriteBaskets;
@property (nonatomic, strong) NSString *userStripeId;

@end

NS_ASSUME_NONNULL_END
