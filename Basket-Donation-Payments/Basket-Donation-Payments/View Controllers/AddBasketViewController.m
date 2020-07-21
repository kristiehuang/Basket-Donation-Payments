//
//  AddBasketViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "AddBasketViewController.h"

@interface AddBasketViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *basketDescriptionTextView;
@property (weak, nonatomic) IBOutlet UITextField *basketNameTextField;

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
