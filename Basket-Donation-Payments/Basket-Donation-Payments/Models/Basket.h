//
//  Basket.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/13/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN
@class Nonprofit;
@class User;

@interface Basket : PFObject<PFSubclassing>

/** Already has createdAt, etc. */
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *basketDescription;
@property (nonatomic, strong) PFFileObject *headerPicFile;
@property (nonatomic) double totalDonatedValue;
@property (nonatomic) BOOL isFeatured;
@property (nonatomic, strong) NSMutableArray<Nonprofit*> *nonprofits;
@property (nonatomic, strong) User *createdByUser;
//TODO: CATEGORY?

+ (Basket*)initNewBasketWithDict:(NSDictionary*)dict;

@end

NS_ASSUME_NONNULL_END
