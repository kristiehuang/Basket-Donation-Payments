//
//  Utils.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "Utils.h"
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>

@implementation Utils

+(UIAlertController *)createAlertControllerWithTitle:(NSString*)title andMessage:(NSString*)message okCompletion:(void(^)(UIAlertAction * action))okCompletion cancelCompletion:(void(^)(UIAlertAction * action))cancelCompletion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:okCompletion];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:cancelCompletion];

    [alert addAction:okAction];
    [alert addAction:cancelAction];
    return alert;
}

+(PFFileObject*)getFileFromImage:(UIImage*)image{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    return [PFFileObject fileObjectWithData:data];
}

+(UIImage*)getImageFromPFFile:(PFFileObject*)file {
    NSData *data = [file getData];
    if (data == nil) {
        return [UIImage imageNamed:@"PlaceholderHeaderPic"];
    } else {
        return [UIImage imageWithData:data];
    }
}

@end
