//
//  Utils.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+(UIAlertController *)createAlertControllerWithTitle:(NSString*)title andMessage:(NSString*)message okCompletion:(void(^)(UIAlertAction * _Nonnull action))okCompletion cancelCompletion:(void(^)(UIAlertAction * _Nonnull action))cancelCompletion;

+(PFFileObject*)getFileFromImage:(UIImage*)image;
@end

NS_ASSUME_NONNULL_END
