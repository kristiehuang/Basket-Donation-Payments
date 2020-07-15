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

+ (Basket*)initPlaceholderTestBasketWithName:(NSString*)name {
    Basket *basket = [Basket new];
    basket.name = name;
    basket.basketDescription = @"";
    
    NSData *headerData = UIImageJPEGRepresentation([UIImage imageNamed:@"PlaceholderHeaderPic"], 1);
    basket.headerPicFile = [PFFileObject fileObjectWithData:headerData];
    basket.totalDonatedValue = 34.0;
    basket.isFeatured = NO;
    basket.nonprofits = [NSArray new];
    basket.createdByUser = [User currentUser];
    return basket;
}

@end
