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
#import "Nonprofit.h"

@implementation Utils

+(UIAlertController *)createAlertControllerWithTitle:(NSString*)title andMessage:(NSString*)message okCompletion:( void(^ _Nullable )(UIAlertAction * action))okCompletion cancelCompletion:(void(^ _Nullable)(UIAlertAction * action))cancelCompletion {
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

+ (void)createImagePickerVCWithVC:(UIViewController*)vc {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = (id<UINavigationControllerDelegate,UIImagePickerControllerDelegate>)vc;
    imagePickerVC.allowsEditing = YES;
    BOOL cameraSourceAvail = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoLibAvail = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    if (cameraSourceAvail && photoLibAvail) {
        //UIActionSheet to pick a source type
        UIAlertController *sourceTypePicker = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            [vc presentViewController:imagePickerVC animated:YES completion:nil];
        }];
        UIAlertAction *photoLib = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [vc presentViewController:imagePickerVC animated:YES completion:nil];
        }];
        [sourceTypePicker addAction:camera];
        [sourceTypePicker addAction:photoLib];
        [vc presentViewController:sourceTypePicker animated:YES completion:nil];
    } else {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [vc presentViewController:imagePickerVC animated:YES completion:nil];
    }
}

+ (UIActivityIndicatorView *)createUIActivityIndicatorViewOnView:(UIView*)view {
    UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    loadingIndicator.hidesWhenStopped = YES;
    loadingIndicator.center = view.center;
    [view addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
    return loadingIndicator;
}

+ (void)getNonprofitImagesFromBasket:(Basket*)basket onCell:(BasketTableViewCell *)cell {
    cell.basketImageView0.layer.cornerRadius = 25;
    cell.basketImageView1.layer.cornerRadius = 25;
    cell.basketImageView2.layer.cornerRadius = 25;
    int nonprofitsCount = (int) basket.nonprofits.count;
    for (int i = 0; i < 3; i++) {
        if (i >= nonprofitsCount) {
            UIImage *im = [UIImage imageNamed:@"PlaceholderProfilePic"];
            switch (i) {
                case 0:
                    cell.basketImageView0.image = im;
                    cell.basketImageView1.image = im;
                    cell.basketImageView2.image = im;
                    break;
                case 1:
                    cell.basketImageView1.image = im;
                    cell.basketImageView2.image = im;
                    break;
                case 2:
                    cell.basketImageView2.image = im;
                    break;
            }
            break;
        }
        Nonprofit *n = basket.nonprofits[i];
        PFFileObject *profFile = n.profilePicFile;
        [profFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            UIImage *im;
            if (error != nil) {
                im = [UIImage imageNamed:@"PlaceholderProfilePic"];
            } else {
                im = [UIImage imageWithData:data];
            }
            switch (i) {
                case 0: cell.basketImageView0.image = im; break;
                case 1: cell.basketImageView1.image = im; break;
                case 2: cell.basketImageView2.image = im; break;
            }
            [cell reloadInputViews];
        }];
    }
}

+ (void)getBasketsWithCompletion:(void(^)(NSArray<Basket*> * _Nullable, NSError * _Nullable))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Basket"];
    [query includeKey:@"nonprofits"];
    [query includeKey:@"nonprofits.verificationFiles"];
    [query includeKey:@"createdByUser"];
    [query includeKey:@"allTransactions"];
    [query includeKey:@"featuredValueDict"];
    [query findObjectsInBackgroundWithBlock:completion];
}


@end
