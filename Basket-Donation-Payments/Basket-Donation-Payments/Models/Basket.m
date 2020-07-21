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
    basket.basketDescription = @"Hey, I’m Kristie! I’m a student at UC Berkeley studying engineering and business, with a particular interest in software dev, product, blockchain, entrepreneurship, and gender equity in tech. Leading operations at she256. Previously design & product intern at a fintech startup, cofounded a fashion tech venture, built and launched two iOS apps to the App Store, and managed a creative magazine. Open to crypto, SWE, product opportunities for summer 2021.";
    
    NSData *headerData = UIImageJPEGRepresentation([UIImage imageNamed:@"PlaceholderHeaderPic"], 1);
    basket.headerPicFile = [PFFileObject fileObjectWithData:headerData];
    basket.totalDonatedValue = 34.0;
    basket.isFeatured = NO;
    basket.nonprofits = [NSMutableArray array];
    basket.createdByUser = [User currentUser];
    return basket;
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
