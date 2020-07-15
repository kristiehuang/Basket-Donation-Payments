//
//  User.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/13/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "User.h"
#import "PFObject+Subclass.h"
#import <Parse/PFSubclassing.h>
#import "Nonprofit.h"

@implementation User

@dynamic firstName;
@dynamic lastName;
@dynamic profilePicFile;
@dynamic nonprofit;
@dynamic recentDonations;
@dynamic favoriteNonprofits;
@dynamic objectId;
@dynamic updatedAt;
@dynamic username;
@dynamic password;
@dynamic email;
@dynamic createdAt;

- (NSString *)parseClassName {
    return @"_User";
}




@end
