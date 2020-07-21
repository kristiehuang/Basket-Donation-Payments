//
//  Basket.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/13/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "Basket.h"
#import "Nonprofit.h"
#import "User.h"

@implementation Basket

@dynamic createdAt;
@dynamic name;
@dynamic basketDescription;
@dynamic headerPicFile;
@dynamic totalDonatedValue;
@dynamic isFeatured;
@dynamic nonprofits;
@dynamic createdByUser;

+ (nonnull NSString *)parseClassName {
    return @"Basket";
}

+ (Basket*)initNewBasketWithDict:(NSDictionary*)dict {
    Basket *basket = [Basket new];
    basket.name = dict[@"name"];
    basket.basketDescription = dict[@"basketDescription"];
    basket.headerPicFile = dict[@"headerPicFile"];
    basket.totalDonatedValue = 0;
    basket.isFeatured = dict[@"isFeatured"];
    basket.createdByUser = [User currentUser];
    basket.nonprofits = [NSMutableArray array];
    return basket;
}

@end
