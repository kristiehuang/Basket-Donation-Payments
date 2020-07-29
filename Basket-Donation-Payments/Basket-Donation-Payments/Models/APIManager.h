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
#import "Basket.h"

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+(NSDictionary*)getAPISecretKeysDict;

+ (void)createPaymentIntentWithBasket:(Basket*)basket totalAmount:(NSNumber*)totalAmount withBlock:(void (^)(NSError *, NSDictionary *))completion;

+ (void)submitPaymentWithCard:(STPPaymentMethodCardParams*)params clientSecret:(NSString*)clientSecret andBlock:(void (^)(NSError *, STPPaymentHandlerActionStatus))completion;

+ (void) newStripeCustomerIdWithName:(NSString*)fullName andEmail:(NSString*)email withBlock:(void (^)(NSError *, NSString *))completion;

@end

NS_ASSUME_NONNULL_END
