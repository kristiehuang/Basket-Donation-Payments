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
@import UITextView_Placeholder;

@interface AddBasketViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@end

@implementation AddBasketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.basketDescriptionTextView.placeholder = @"Describe your basket.";
    self.basketDescriptionTextView.placeholderColor = [UIColor lightGrayColor];
    self.basketNameTextField.delegate = self;
    self.basketCategoryTextField.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(endEditing:)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)nextButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"addNonprofitsSegue" sender:nil];
}

- (IBAction)headerImageButtonTapped:(id)sender {
    [Utils createImagePickerVCWithVC:self];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    self.basketHeaderImageView.image = editedImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addNonprofitsSegue"]) {
        AddBasket_AddNonprofitsViewController *nextVC = [segue destinationViewController];
        nextVC.basket = [Basket initWithName:self.basketNameTextField.text description:self.basketDescriptionTextView.text headerPicFile:[Utils getFileFromImage:self.basketHeaderImageView.image] category:self.basketCategoryTextField.text];
    }
}

- (void) resetForm {
    self.basketNameTextField.text = @"";
    self.basketCategoryTextField.text = @"";
    self.basketDescriptionTextView.text = @"";
    self.basketDescriptionTextView.placeholder = @"Describe your basket.";
    self.basketDescriptionTextView.placeholderColor = [UIColor lightGrayColor];
    self.basketHeaderImageView.image = [UIImage imageNamed:@"PlaceholderHeaderPic"];
}

@end
