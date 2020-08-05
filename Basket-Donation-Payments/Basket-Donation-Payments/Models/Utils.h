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

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+(UIAlertController *)createAlertControllerWithTitle:(NSString*)title andMessage:(NSString*)message okCompletion:(void(^ _Nullable)(UIAlertAction * _Nonnull action))okCompletion cancelCompletion:(void(^ _Nullable)(UIAlertAction * _Nonnull action))cancelCompletion;

+(PFFileObject*)getFileFromImage:(UIImage*)image;
+(UIImage*)getImageFromPFFile:(PFFileObject*)file;
+ (void)createImagePickerVCWithVC:(UIViewController*)vc;
+ (UIActivityIndicatorView *)createUIActivityIndicatorViewOnView:(UIView*)view;

@end


NS_ASSUME_NONNULL_END
