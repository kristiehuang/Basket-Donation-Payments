//
//  AddBasket-AddNonprofitsViewController.m
//  Basket Donation Payments
//
//  Created by Kristie Huang on 7/21/20.
//  Copyright © 2020 Kristie Huang. All rights reserved.
//

#import "AddBasket-AddNonprofitsViewController.h"
#import "AddBasketViewController.h"
#import "Nonprofit.h"
#import <Parse/Parse.h>
#import "Utils.h"
#import "NonprofitListCell.h"

@interface AddBasket_AddNonprofitsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *selectNonprofitsTableView;
@property (nonatomic, strong) NSArray<Nonprofit*> *allNonprofits;
@end

@implementation AddBasket_AddNonprofitsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectNonprofitsTableView.delegate = self;
    self.selectNonprofitsTableView.dataSource = self;
    [self getAllNonprofitsFromParse];
    self.selectNonprofitsTableView.allowsMultipleSelection = YES;
    self.navigationController.navigationBar.hidden = NO;

}

- (void)getAllNonprofitsFromParse {
    PFQuery *nonprofitQuery = [PFQuery queryWithClassName:@"Nonprofit"];
    [nonprofitQuery includeKey:@"profilePicFile"];
    UIActivityIndicatorView *loadingIndicator = [Utils createUIActivityIndicatorViewOnView:self.view];
    [nonprofitQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil) {
                [loadingIndicator stopAnimating];
                UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Cannot get nonprofits. Try again?" andMessage:error.localizedDescription okCompletion:^(UIAlertAction * _Nonnull action) {
                    [self getAllNonprofitsFromParse];
                } cancelCompletion:nil];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                self.allNonprofits = objects;
                [self.selectNonprofitsTableView reloadData];
                [loadingIndicator stopAnimating];
            }
        });
    }];
}

- (IBAction)createButtonTapped:(id)sender {
    if (self.basket.nonprofits.count == 0) {
        UIAlertController *didNotAddNonprofits = [Utils createAlertControllerWithTitle:@"Did not select nonprofits." andMessage:@"Please select at least two nonprofits you'd like donations to go towards." okCompletion:nil cancelCompletion:nil];
        [self presentViewController:didNotAddNonprofits animated:YES completion:nil];
    } else {
        UIActivityIndicatorView *loadingIndicator = [Utils createUIActivityIndicatorViewOnView:self.view];
        [self.basket saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingIndicator stopAnimating];
                if (succeeded) {
                    AddBasketViewController *rootVC = self.navigationController.viewControllers.firstObject;
                    [rootVC resetForm];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    self.tabBarController.selectedIndex = 0;
                } else {
                    UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save Basket. Try again?" andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            });
        }];
    }
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NonprofitListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NonprofitListCell"];
    Nonprofit *nonprofit = self.allNonprofits[indexPath.row];
    cell.nonprofitNameLabel.text = nonprofit.nonprofitName;
    cell.nonprofitDescriptionLabel.text = nonprofit.nonprofitDescription;
    cell.nonprofitProfileImageView.image = [Utils getImageFromPFFile:nonprofit.headerPicFile];
    
    NSArray<NSIndexPath *> *selectedIndexes = [tableView indexPathsForSelectedRows];
    BOOL isSelected = selectedIndexes != nil && [selectedIndexes containsObject:indexPath];
    cell.accessoryType = isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allNonprofits.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Nonprofit *nonprofit = self.allNonprofits[indexPath.row];
    NonprofitListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [self.basket.nonprofits addObject:nonprofit];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    Nonprofit *nonprofit = self.allNonprofits[indexPath.row];
    NonprofitListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [self.basket.nonprofits removeObject:nonprofit];
}

@end
