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
#import "BasketTransaction.h"
#import "FeaturedValueWeight.h"

@implementation Basket

@dynamic createdAt;
@dynamic name;
@dynamic basketDescription;
@dynamic headerPicFile;
@dynamic totalDonatedValue;
@dynamic isFeatured;
@dynamic nonprofits;
@dynamic category;
@dynamic totalFeaturedValue;
@dynamic nonprofitPercentages;
@dynamic createdByUser;
@dynamic allTransactions;
@dynamic featuredValueWeights;
@dynamic favoriteCount;

+ (nonnull NSString *)parseClassName {
    return @"Basket";
}

+ (Basket*)initWithName:(NSString*)basketName description:(NSString*)basketDescription headerPicFile:(PFFileObject*)headerPicFile category:(NSString*)category {
    Basket *basket = [Basket new];
    basket.name = basketName;
    basket.basketDescription = basketDescription;
    basket.category = category;
    basket.headerPicFile = headerPicFile;
    basket.totalDonatedValue = @0;
    basket.favoriteCount = 0;
    basket.isFeatured = @NO;
    basket.totalFeaturedValue = @0;
    basket.allTransactions = [NSMutableArray array];
    basket.featuredValueWeights = [FeaturedValueWeight initNewFeaturedValueWeights];
    basket.createdByUser = [User currentUser];
    basket.nonprofits = [NSMutableArray array];
    basket.nonprofitPercentages = [NSMutableDictionary new];
    return basket;
}

@end
