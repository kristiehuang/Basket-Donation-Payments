//
//  ProfileViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/14/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "AppDelegate.h"
#import "SceneDelegate.h"
#import "InitialLoginViewController.h"
#import "Utils.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userEmailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePicImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *personalNonprofitSegmentedControl;
@property (nonatomic, strong) User *user;
@property (weak, nonatomic) IBOutlet UIView *nonprofitView;
@property (weak, nonatomic) IBOutlet UIView *personalView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [User currentUser];
    self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user.firstName, self.user.lastName];
    self.userUsernameLabel.text = self.user.username;
    self.userEmailLabel.text = self.user.email;
    self.userProfilePicImageView.layer.cornerRadius = self.userProfilePicImageView.frame.size.width / 2;
    [self.user.profilePicFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error != nil) {
            self.userProfilePicImageView.image = [UIImage imageNamed:@"PlaceholderProfilePic"];
        } else {
            UIImage *image = [UIImage imageWithData:data];
            self.userProfilePicImageView.image = image;
        }
    }];
    if (self.user.nonprofit == nil) {
        self.personalNonprofitSegmentedControl.hidden = YES;
        self.nonprofitView.hidden = YES;
    } else {
        self.nonprofitView.hidden = YES;
        self.personalView.hidden = NO;
    }
}
- (IBAction)segmentedControlValueChanged:(id)sender {
    switch (self.personalNonprofitSegmentedControl.selectedSegmentIndex) {
        case 0:
            self.nonprofitView.hidden = YES;
            self.personalView.hidden = NO;
            break;
        case 1:
            self.nonprofitView.hidden = NO;
            self.personalView.hidden = YES;
            break;
        default:
            break;
    }
}

- (IBAction)paymentMethodTapped:(id)sender {
}

- (IBAction)logoutButtonTapped:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error == nil) {
            SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            InitialLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"InitialLoginViewController"];
            myDelegate.window.rootViewController = loginVC;
        } else {
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Cannot logout." andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
            [self presentViewController:alert animated:YES completion:nil];
        }

    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
