//
//  FeaturedValueWeight.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 8/3/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "FeaturedValueWeight.h"

@implementation FeaturedValueWeight

@dynamic numberOfDonationsWeight;
@dynamic predeterminedEventRelevancyWeight;
@dynamic userFavoritesWeight;

+ (FeaturedValueWeight*)initNewFeaturedValueWeights {
    FeaturedValueWeight *fvw = [FeaturedValueWeight new];
    return fvw;
}


+ (nonnull NSString *)parseClassName { 
    return @"FeaturedValueWeight";
}

@end
