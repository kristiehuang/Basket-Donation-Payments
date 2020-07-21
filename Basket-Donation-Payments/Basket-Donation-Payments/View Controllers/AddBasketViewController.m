//
//  AddBasketViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "AddBasketViewController.h"
#import "AddBasket-AddNonprofitsViewController.h"
#import "Basket.h"
#import "Utils.h"

@interface AddBasketViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *basketDescriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *basketNameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *basketHeaderImageView;
@property (weak, nonatomic) IBOutlet UITextField *basketCategoryTextField;

@end

@implementation AddBasketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.basketDescriptionTextView.delegate = self;
    self.basketDescriptionTextView.text = @"Describe your basket in 100 words or less.";
    self.basketDescriptionTextView.textColor = [UIColor lightGrayColor];
    
}

- (IBAction)nextButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"addNonprofitsSegue" sender:nil];
    //save info, create basket
    //switch tab controller to index 0
}

- (IBAction)headerImageButtonTapped:(id)sender {
        UIImagePickerController *imagePickerVC = [UIImagePickerController new];
        imagePickerVC.delegate = self;
        imagePickerVC.allowsEditing = YES;
        BOOL cameraSourceAvail = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        BOOL photoLibAvail = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
        if (cameraSourceAvail && photoLibAvail) {
            //UIActionSheet to pick a source type
            UIAlertController *sourceTypePicker = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            }];
            UIAlertAction *photoLib = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }];
            [sourceTypePicker addAction:camera];
            [sourceTypePicker addAction:photoLib];
            [self presentViewController:sourceTypePicker animated:YES completion:nil];
        } else {
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    self.basketHeaderImageView.image = editedImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addNonprofitsSegue"]) {

        NSDictionary *dict = @{
            @"name": self.basketNameTextField.text,
            @"basketDescription": self.basketDescriptionTextView.text,
            @"headerPicFile": [Utils getFileFromImage:self.basketHeaderImageView.image],
            @"isFeatured": @NO,
        };
        AddBasket_AddNonprofitsViewController *nextVC = [segue destinationViewController];
        nextVC.basket = [Basket initNewBasketWithDict:dict];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.textColor isEqual:[UIColor lightGrayColor]]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.basketDescriptionTextView.text = @"Describe your basket in 100 words or less.";
        self.basketDescriptionTextView.textColor = [UIColor lightGrayColor];
    }
}

@end
