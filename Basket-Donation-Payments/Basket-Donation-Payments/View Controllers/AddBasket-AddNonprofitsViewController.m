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

}

- (void)getAllNonprofitsFromParse {
    PFQuery *nonprofitQuery = [PFQuery queryWithClassName:@"Nonprofit"];
    [nonprofitQuery includeKey:@"profilePicFile"];
    
    [nonprofitQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error != nil) {
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Cannot get nonprofits. Try again?" andMessage:error.localizedDescription okCompletion:^(UIAlertAction * _Nonnull action) {
                [self getAllNonprofitsFromParse];
            } cancelCompletion:nil];
            [self presentViewController:alert animated:YES completion:nil];

        } else {
            self.allNonprofits = objects;
            [self.selectNonprofitsTableView reloadData];
        }
    }];
}

- (IBAction)createButtonTapped:(id)sender {
    NSLog(@"%@", self.basket.nonprofits);
    [self.basket saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            AddBasketViewController *rootVC = self.navigationController.viewControllers.firstObject;
            rootVC.basketNameTextField.text = @"";
            rootVC.basketCategoryTextField.text = @"";
            rootVC.basketDescriptionTextView.text = @"Describe your basket in 100 words or less.";
            rootVC.basketDescriptionTextView.textColor = [UIColor lightGrayColor];
            rootVC.basketHeaderImageView.image = [UIImage imageNamed:@"PlaceholderHeaderPic"];
            [self.navigationController popToRootViewControllerAnimated:YES];
            self.tabBarController.selectedIndex = 0;
        } else {
            UIAlertController *alert = [Utils createAlertControllerWithTitle:@"Could not save Basket. Try again?" andMessage:error.localizedDescription okCompletion:nil cancelCompletion:nil];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NonprofitListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NonprofitListCell"];
    Nonprofit *nonprofit = self.allNonprofits[indexPath.row];
    cell.nonprofitNameLabel.text = nonprofit.nonprofitName;
    cell.nonprofitDescriptionLabel.text = nonprofit.nonprofitDescription;
    cell.nonprofitProfileImageView.image = [Utils getImageFromPFFile:nonprofit.headerPicFile];
    
    NSArray<NSIndexPath *> *selectedIndexes = [tableView indexPathsForSelectedRows];
    BOOL isSelected = selectedIndexes != nil && [selectedIndexes containsObject:indexPath];
    if (isSelected) {
        cell.contentView.backgroundColor = [UIColor blueColor];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allNonprofits.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Nonprofit *nonprofit = self.allNonprofits[indexPath.row];
    NSLog(@"selected %@", nonprofit.nonprofitName);
    //FIXME: color change when selected doesn't work
    NonprofitListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor blueColor];
    [self.basket.nonprofits addObject:nonprofit];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    Nonprofit *nonprofit = self.allNonprofits[indexPath.row];
    NSLog(@"deselected %@", nonprofit.nonprofitName);

    NonprofitListCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //FIXME: color change when deselected doesn't work
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.basket.nonprofits removeObject:nonprofit];
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
