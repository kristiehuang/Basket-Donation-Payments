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
@class BasketTransaction;

@interface Basket : PFObject<PFSubclassing>

/** Already has createdAt, etc. */
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *basketDescription;
@property (nonatomic, strong) PFFileObject *headerPicFile;
@property (nonatomic, strong) NSMutableArray<BasketTransaction*> *allTransactions;
@property (nonatomic, strong) NSNumber *totalDonatedValue;

/** Max of 100; 40% number of donations, 30% built-in current event relevancy, 30% user-selected favorite categories.
    featuredValue: { numberOfDonations: 30, predeterminedEventRelevancy: 30 userFavorite: 0 }

    totalFeaturedValue: 60 */
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSNumber*> *featuredValueDict;
@property (nonatomic, strong) NSNumber *totalFeaturedValue;
@property (nonatomic) BOOL isFeatured;

@property (nonatomic, strong) NSMutableArray<Nonprofit*> *nonprofits;
@property (nonatomic, strong) NSMutableDictionary<Nonprofit*, NSNumber*> *nonprofitPercentages;

@property (nonatomic, strong) User *createdByUser;
//TODO: CATEGORY?

+ (Basket*)initWithName:(NSString*)basketName description:(NSString*)basketDescription headerPicFile:(PFFileObject*)headerPicFile;
@end

NS_ASSUME_NONNULL_END
