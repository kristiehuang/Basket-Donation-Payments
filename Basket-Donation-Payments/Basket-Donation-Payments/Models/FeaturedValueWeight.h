//
//  FeaturedValueWeight.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 8/3/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

/** All weight categories add up to 100%; the top 3 baskets with the highest FeaturedValues are considered Featured Baskets. */

@interface FeaturedValueWeight : PFObject<PFSubclassing>

/** 40% of featuredValue calculation. The more donations a basket has, the more popular it is. */
@property (nonatomic) NSInteger numberOfDonationsWeight;

/** Predetermined & hard-coded by app creator. 30% of featuredValue calculation. */
@property (nonatomic) NSInteger predeterminedEventRelevancyWeight;

/** 30% of featuredValue calculation. The more favorites a basket has, the more liked it is. */
@property (nonatomic) NSInteger userFavoritesWeight;


+ (FeaturedValueWeight*)initNewFeaturedValueWeights;

@end

NS_ASSUME_NONNULL_END
