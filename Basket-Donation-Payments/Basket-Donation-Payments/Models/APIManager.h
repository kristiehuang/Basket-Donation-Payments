//
//  APIManager.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFOAuth2Manager.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

-(NSDictionary*)getAPISecretKeysDict;


@end

NS_ASSUME_NONNULL_END
