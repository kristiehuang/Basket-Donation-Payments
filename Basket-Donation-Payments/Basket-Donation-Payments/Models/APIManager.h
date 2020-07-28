//
//  APIManager.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFOAuth2Manager.h"
#import <Stripe/Stripe.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+(NSDictionary*)getAPISecretKeysDict;
+ (void)createPaymentIntentWithBlock:(void (^)(NSError *, NSDictionary *))completion;
+ (void)submitPaymentWithCard:(STPPaymentMethodCardParams*)params clientSecret:(NSString*)clientSecret andBlock:(void (^)(NSError *, STPPaymentHandlerActionStatus))completion;
@end

NS_ASSUME_NONNULL_END
