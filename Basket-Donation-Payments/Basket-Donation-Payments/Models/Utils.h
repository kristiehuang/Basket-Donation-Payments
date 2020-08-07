//
//  Utils.h
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "BasketTableViewCell.h"
#import "Basket.h"

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+(UIAlertController *)createAlertControllerWithTitle:(NSString*)title andMessage:(NSString*)message okCompletion:(void(^ _Nullable)(UIAlertAction * _Nonnull action))okCompletion cancelCompletion:(void(^ _Nullable)(UIAlertAction * _Nonnull action))cancelCompletion;

+(PFFileObject*)getFileFromImage:(UIImage*)image;
+(UIImage*)getImageFromPFFile:(PFFileObject*)file;
+ (void)createImagePickerVCWithVC:(UIViewController*)vc;
+ (UIActivityIndicatorView *)createUIActivityIndicatorViewOnView:(UIView*)view;
+ (void)getNonprofitImagesFromBasket:(Basket*)basket onCell:(BasketTableViewCell *)cell;
+ (void)getBasketsWithCompletion:(void(^)(NSArray<Basket*> * _Nullable, NSError * _Nullable))completion;

@end


NS_ASSUME_NONNULL_END
